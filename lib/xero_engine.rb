require 'xero_engine/engine'

module XeroEngine
  require 'devise'
  require 'xeroizer'
  require 'jquery-rails'
  require 'high_voltage'
  require 'money-rails'
  require 'rack/timeout'
  require 'redis'
  require 'sinatra'
  require 'pundit'
# require 'xeroizer'
  require 'wicked'
  # require 'sidekiq'
  # require 'sidekiq/web'
  # require 'sidetiq'
  require 'flutie'
  require 'simple_form'
  require 'stripe-rails'
  require 'bootstrap-sass'

  # Enable High Voltage routes to extend our routes
  HighVoltage.parent_engine = XeroEngine::Engine


end
