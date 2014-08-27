source "https://rubygems.org"

# Declare your gem's dependencies in xero_engine.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'

gem 'sidetiq', github: 'tobiassvn/sidetiq'
gem "xeroizer", github: "adamburmister/xeroizer"
gem 'country_select', github: 'stefanpenner/country_select'

group :staging, :production do
  gem 'rails_12factor'
  gem "newrelic_rpm", ">= 3.7.3"
end
