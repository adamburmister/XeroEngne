class OrganisationMailer < ActionMailer::Base
  default from: ENV.fetch('CUSTOMER_SUPPORT_EMAIL')
end
