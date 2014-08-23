class RecurringWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly }

  def perform
    # Schedule a task to check an organisation for overdue invoices matching the orgs rules
    # Organisation.select(:organisation_id, :short_code).where(is_demo_company: false).all do |org|
      # TODO: Do stuff with it
    # end
  end
end