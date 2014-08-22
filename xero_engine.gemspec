$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "xero_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "xero_engine"
  s.version     = XeroEngine::VERSION
  s.authors     = ["Adam Burmister"]
  s.email       = ["adam.burmister@gmail.com"]
  s.homepage    = "http://www.burmister.com"
  s.summary     = "Xero partner addon Rails Engine."
  s.description = "Xero partner addon Rails Engine."
  s.license     = "© Adam Burmister 2014, All rights reserved"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.4"

  s.add_development_dependency "sqlite3"
end
