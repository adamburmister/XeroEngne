module XeroEngine
  class OrganisationMembershipsController < XeroEngine::AuthorisedController

    skip_before_filter :ensure_current_organisation

    def index
      @organisation_memberships = current_user.organisation_memberships
    end

    def new
      oauth_callback_url = "#{ENV.fetch('SITE_URL')}/oauth/callback"

      Rails.logger.info "Requesting OAuth access with callback #{oauth_callback_url}"

      request_token = xero_client.request_token(:oauth_callback => oauth_callback_url)
      session[:request_token] = request_token.token
      session[:request_secret] = request_token.secret

      redirect_to request_token.authorize_url
    end

    def create
      xero_client.authorize_from_request session[:request_token], session[:request_secret], oauth_verifier: params[:oauth_verifier]

      # Clean up the session
      session[:request_token] = nil
      session[:request_secret] = nil

      # Track the currently logged in organisation
      @organisation = XeroOrganisationSyncService.new(current_user, xero_client).create_or_update!
      set_current_organisation_short_code @organisation.short_code

      render :callback, layout: false

    rescue OAuth::Unauthorized
      redirect_to organisation_memberships_path, alert: "Failed to connect to Xero. Try again."
    end

    def show
      # Switch organisations
      @membership = current_user.organisation_memberships.find(params[:id])
      authorize @membership
      set_current_organisation_short_code @membership.short_code
      flash.clear # Start with a new slate for this org
      redirect_to root_path
    end

    def expired
      hide_secondary_navbar

      @membership = current_user.organisation_memberships.find(params[:id])
      authorize @membership

      @organisation = @membership.organisation
      set_current_organisation_short_code @membership.short_code
    end

    def destroy
      @membership = current_user.organisation_memberships.find(params[:id])
      authorize @membership

      flash[:success] = I18n.t 'organisation_membership.destruction.success', organisation_name: @membership.organisation.name, :scope => [:xero_engine]
      @membership.destroy!

      set_current_organisation_short_code nil

      redirect_to root_path
    end

  protected

    def xero_client
      @xero_client ||= Xeroizer::PublicApplication.new Rails.application.secrets.xero_consumer_key, Rails.application.secrets.xero_consumer_secret
    end

  end
end