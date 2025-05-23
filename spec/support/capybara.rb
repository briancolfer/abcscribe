require 'capybara/rspec'

RSpec.configure do |config|
  config.include Capybara::DSL, type: :feature
  
  # Configure Capybara
  Capybara.server = :puma
  Capybara.default_max_wait_time = 5
end

