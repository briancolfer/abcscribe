require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Abcscribe
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks templates))

    # Configuration for the application, engines, and railties goes here.
    config.autoload_paths += %W(#{config.root}/app/models/concerns)
    config.autoload_paths += %W(#{config.root}/app/controllers/concerns)
    
    # Don't generate system test files.
    config.generators.system_tests = nil

    # Autoload lib directory
    config.autoload_paths << Rails.root.join('lib')

    # Configure CORS
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'  # Configure this appropriately for production
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          expose: ['Authorization']
      end
    end
    
    # Configure time zone
    config.time_zone = "UTC"
    
    # Configure test framework
    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: true,
        routing_specs: false,
        controller_specs: true,
        request_specs: true
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end
  end
end
