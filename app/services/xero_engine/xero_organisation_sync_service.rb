module XeroEngine
  class XeroOrganisationSyncService
    @@permitted_latest_org_attributes = [
      :name, :legal_name, :version, :organisation_type, :base_currency,
      :country_code, :is_demo_company, :organisation_status
    ]

    def initialize(user, xero_client)
      @user = user
      @xero_client = xero_client
    end

    # Update the existing local organisation model from the Xero API
    def update!
      sync!(false)
    end

    # Create or update the local organisation model from the Xero API
    # @return Organisation
    def create_or_update!
      sync!(true)
    end

    protected

    # @param can_create {boolean} Allow creation of models, not just updates
    def sync!(can_create=false)
      # Cache into easier to use vars
      access_token = @xero_client.access_token.token
      access_secret = @xero_client.access_token.secret

      # Authorise the client to access with this token
      # @xero_client.authorize_from_access access_token, access_secret

      # Create or update organisation membership details
      latest_xero_org_response = @xero_client.Organisation.first
      short_code = latest_xero_org_response.short_code

      # Collect attributes of the Xero response into a hash which we can use to
      # update/build our local Organisation model. (Strip out keys we don't need)
      latest_org_attributes = latest_xero_org_response.attributes.slice(*@@permitted_latest_org_attributes)
                                                      .merge!({ last_synced_at: DateTime.now })

      # At the end of this method the membership will contain these values
      latest_membership_attributes = {
        access_token: access_token,
        access_secret: access_secret
      }

      # Find the first membership or build a new one (if can_create is true)
      membership = @user.organisation_memberships.where({ short_code: short_code }).first ||
                   (can_create ? @user.organisation_memberships.build({ short_code: short_code }) : nil)

      raise "Membership not found for User #{@user.id} and Org #{short_code}" if membership.nil?

      # Update the membership to refrect access token and sync date
      membership.assign_attributes(latest_membership_attributes)

      if can_create && membership.new_record?
        # We now need to add the organisation model to the membership. This could be in 2 states:
        # 1. This organisation has never existed within our app before, and we need to create one
        # 2. Another user has added this organisation to our app, and we need to link to it (and update it)
        existing_org = Organisation.where(short_code: short_code).first
        if existing_org.nil?
          membership.build_organisation short_code: short_code
        else
          membership.organisation = existing_org
        end
      end

      # Sync Xero API response with the existing local Organisation model
      membership.organisation.assign_attributes(latest_org_attributes)

      # Save our changes to Membership and Organisation
      membership.save!

      return membership.organisation
    end

  end
end