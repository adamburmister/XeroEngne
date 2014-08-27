module XeroEngine::XeroClient
  extend ActiveSupport::Concern

  # @return {Xeroizer::PublicApplication} configured client with access to the #current_organisation
  def xero_client
    @xero_client ||= Xeroizer::PublicApplication.new Rails.application.secrets.xero_consumer_key, Rails.application.secrets.xero_consumer_secret, :logger => Rails.logger
    if current_organisation?
      membership = current_user.organisation_memberships.where(short_code: current_organisation_short_code).first
      @xero_client.authorize_from_access membership.access_token, membership.access_secret if membership.present?
    end
    @xero_client
  end

end