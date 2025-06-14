source "https://rubygems.org"

ruby "3.4.4"

# Rails and core gems
gem "rails", "~> 8.0.2"
gem "propshaft"
gem "sqlite3", ">= 2.1"
gem "puma", ">= 5.0"
gem "bcrypt", "~> 3.1"
gem "bootsnap", require: false

# Frontend
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"
gem "kaminari"

# API related gems
gem "jsonapi-serializer"  # For JSON:API compliant serialization
gem "rack-cors"           # For handling Cross-Origin Resource Sharing
gem "jwt"                 # For token-based authentication

# Background processing and caching
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Deployment
gem "kamal", require: false
gem "thruster", require: false

## Custom validations are implemented in models

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.5"
  gem "letter_opener", "~> 1.0" # For previewing emails in development
  gem "shoulda-matchers", "~> 6.1"
  gem "rswag"              # For API documentation
end

group :development do
  gem "web-console"
end
group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "rack_session_access"
  gem "selenium-webdriver"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]
