Devise.setup do |config|
  config.router_name = :xero_engine
  config.parent_controller = 'XeroEngine::ApplicationController'
  config.mailer_sender = ENV.fetch('CUSTOMER_SUPPORT_EMAIL')
  config.mailer = 'XeroEngine::DeviseMailer'
end