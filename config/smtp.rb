require 'uri'

SMTP_SETTINGS = {
  address: ENV.fetch("SMTP_ADDRESS"), # example: "smtp.sendgrid.net"
  authentication: :plain,
  domain: ENV.fetch('SITE_HOST'),
  enable_starttls_auto: true,
  user_name: Rails.application.secrets.sendgrid_username,
  password: Rails.application.secrets.sendgrid_password,
  port: "587"
}