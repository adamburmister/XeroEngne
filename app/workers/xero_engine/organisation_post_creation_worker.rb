class OrganisationPostCreationWorker
  include Sidekiq::Worker

  def perform(short_code)
    # Sync the org data
    XeroOrganisationSyncWorker.perform_async(short_code)
    
    # TODO: Anything else needed after we create a new organisation
  end

end