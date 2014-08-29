$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "xero_engine/version"

# Describe your s.add_dependency and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "xero_engine"
  s.version     = XeroEngine::VERSION
  s.authors     = ["Adam Burmister"]
  s.email       = ["adam.burmister@gmail.com"]
  s.homepage    = "http://www.burmister.com"
  s.summary     = "Xero partner addon Rails Engine."
  s.description = "Xero partner addon Rails Engine."
  s.license     = "© Adam Burmister 2014, All Rights Reserved"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.4"

  # Suspenders
  s.add_dependency "coffee-rails"
  s.add_dependency "email_validator"
  s.add_dependency "flutie"
  s.add_dependency "high_voltage", '~> 2.2.1'
  s.add_dependency "jquery-rails"
  s.add_dependency "pg"
  s.add_dependency "rack-timeout"
  s.add_dependency "recipient_interceptor"
  s.add_dependency 'bootstrap-sass', '~> 3.2.0'
  s.add_dependency "sass-rails", "~> 4.0.3"
  s.add_dependency "simple_form", "~> 3.1.0.rc2"
  s.add_dependency "title"
  s.add_dependency "uglifier"
  s.add_dependency "unicorn"

  # Add on's
  s.add_dependency "devise" # authentication
  s.add_dependency "pundit" # authorization
  s.add_dependency 'stripe-rails'
  s.add_dependency 'sinatra', '>= 1.3.0'
  s.add_dependency 'sidekiq'
  s.add_dependency 'sidekiq-failures'
  s.add_dependency 'sidekiq_mailer'
  s.add_dependency 'money-rails'
  s.add_dependency 'roadie-rails' # email style inlining

  # Development
  s.add_development_dependency "foreman"
  s.add_development_dependency "spring"
  s.add_development_dependency "spring-commands-rspec"
  s.add_development_dependency 'better_errors'
  s.add_development_dependency 'binding_of_caller'
  s.add_development_dependency "awesome_print"
  s.add_development_dependency "dotenv-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "rspec-rails", "~> 3.0.0"
  s.add_development_dependency "capybara-webkit", ">= 1.2.0"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "formulaic"
  s.add_development_dependency "launchy"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "timecop"
  s.add_development_dependency "webmock"
  s.add_development_dependency 'simplecov'
end
