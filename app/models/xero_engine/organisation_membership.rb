# Associates Users with Organisations in a many-to-many way
module XeroEngine
  class OrganisationMembership < ActiveRecord::Base

    # AR Callbacks
    after_destroy :after_destroy

    # Relationships
    belongs_to :user
    belongs_to :organisation, autosave: true

    # Validations
    validates :short_code,
              presence: true,
              uniqueness: { scope: :user_id },
              length: { maximum: 10 }

    def expired?
      expired = access_token.blank?
      expired ||= (expires_at > DateTime.now) if expires_at.present?
      expired ||= (authorization_expires_at > DateTime.now) if authorization_expires_at.present?
      expired
    end

    def after_destroy
      if !organisation.active?
        # Just in case we have some odd reason where we've deleted this from stripe already
        if organisation.stripe_customer
          organisation.stripe_customer.metadata.tap do |meta|
            meta.deleted = true
            meta.deleted_at = DateTime.now.to_s
            meta.deleted_by_id = user.id
            meta.deleted_by_name = user.name
            meta.deleted_by_email = user.email
          end
          organisation.stripe_customer.description = "[DEL] " + organisation.stripe_customer.description
          organisation.stripe_customer.save
        end

        organisation.stripe_customer_id = nil
        organisation.save
      end
    end

  end
end