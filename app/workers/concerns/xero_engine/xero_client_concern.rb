module XeroClientConcern
  extend ActiveSupport::Concern

  # @return {Xeroizer::PublicApplication} configured client with access to the #current_organisation
  def configure_xero_client(organisation_id)
    @xero_client ||= Xeroizer::PublicApplication.new Rails.application.secrets.xero_consumer_key, Rails.application.secrets.xero_consumer_secret    
    membership = OrganisationMembership.find(organisation_id)
    @xero_client.authorize_from_access membership.access_token, membership.access_secret
    @xero_client
  end

  def xero_client
    @xero_client
  end

end