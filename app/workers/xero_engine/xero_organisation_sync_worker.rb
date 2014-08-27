module XeroEngine
  class XeroOrganisationSyncWorker
    include Sidekiq::Worker
    include XeroClientConcern

    sidekiq_options retry: 1, backtrace: true

    def perform(short_code)
      membership = OrganisationMembership.find_by_short_code(short_code)
      raise "No access token exists for #{short_code}" if !membership || membership.access_token.nil? || membership.access_secret.nil?

      XeroOrganisationSyncService.new(membership.user, configure_xero_client(membership.organisation_id)).update!
    end

  end
end