require 'rails_helper'

# This is an EXAMPLE spec showing how to test Devise timeoutable functionality
# To enable these tests, you would need to:
# 1. Add :timeoutable to the User model's devise modules
# 2. Uncomment and configure config.timeout_in in config/initializers/devise.rb
# 3. Remove the 'skip' from the describe block below

RSpec.describe 'Session timeout behaviour', type: :system, skip: 'Example only - requires timeoutable to be enabled' do
  # To enable timeoutable functionality, you would need to:
  #
  # 1. Modify app/models/user.rb:
  #    devise :database_authenticatable, :registerable,
  #           :recoverable, :rememberable, :validatable, :timeoutable
  #
  # 2. Modify config/initializers/devise.rb:
  #    config.timeout_in = 5.minutes
  #
  # 3. Optionally run migration to add any needed columns (usually not required for timeoutable)
  
  let(:user) { create(:user) }
  
  describe 'Session timeout after idle period' do
    before do
      # Ensure timeoutable is enabled
      expect(User.devise_modules).to include(:timeoutable)
      
      # Clean slate for each test
      Capybara.reset_sessions!
    end
    
    it 'redirects to sign in after timeout period with appropriate message' do
      # Sign in user normally
      complete_sign_in(
        email: user.email,
        password: user.password
      )
      expect_sign_in_success
      
      # Simulate time passing beyond the timeout period
      # Using Rails 6+ travel_to method
      travel_to(6.minutes.from_now) do
        # Try to access a protected page
        visit journal_entries_path
        
        # Should be redirected to sign in
        expect(current_path).to eq("/users/sign_in")
        
        # Should show timeout message
        expect(page).to have_content("Your session expired. Please sign in again to continue.")
      end
    end
    
    it 'maintains session when user is active within timeout window' do
      # Sign in user
      complete_sign_in(
        email: user.email,
        password: user.password
      )
      expect_sign_in_success
      
      # Make activity within timeout period (assuming 5 minute timeout)
      travel_to(3.minutes.from_now) do
        visit root_path
        expect_user_to_be_signed_in
        expect(page).to have_content("Hello, #{user.email}!")
      end
      
      # Make another activity still within the reset timeout window
      travel_to(6.minutes.from_now) do
        visit journal_entries_path
        expect(current_path).to eq(journal_entries_path)
        expect_user_to_be_signed_in
      end
    end
    
    it 'resets timeout period with each user activity' do
      # Sign in user
      complete_sign_in(
        email: user.email,
        password: user.password
      )
      expect_sign_in_success
      
      # Make requests every 3 minutes for 15 minutes
      # Each request should reset the 5-minute timeout period
      [3, 6, 9, 12, 15].each do |minutes|
        travel_to(minutes.minutes.from_now) do
          visit root_path
          expect_user_to_be_signed_in
          expect(page).to have_content("Hello, #{user.email}!")
        end
      end
    end
    
    it 'does not timeout when remember token is present' do
      # Sign in with remember me checked
      complete_sign_in(
        email: user.email,
        password: user.password,
        remember_me: true
      )
      expect_sign_in_success
      
      # Wait beyond session timeout period
      travel_to(10.minutes.from_now) do
        visit journal_entries_path
        
        # Should still be logged in due to remember token
        expect(current_path).to eq(journal_entries_path)
        expect_user_to_be_signed_in
      end
    end
  end
  
  describe 'Timeout configuration validation' do
    it 'has timeoutable module enabled' do
      expect(User.devise_modules).to include(:timeoutable)
    end
    
    it 'has timeout configured' do
      expect(Devise.timeout_in).to be_present
      expect(Devise.timeout_in).to be_a(ActiveSupport::Duration)
    end
  end
  
  describe 'Session timeout with AJAX requests' do
    it 'returns appropriate response for timed out AJAX requests', js: true do
      # Sign in user
      complete_sign_in(
        email: user.email,
        password: user.password
      )
      expect_sign_in_success
      
      # Fast forward beyond timeout
      travel_to(10.minutes.from_now) do
        # Make an AJAX request (this would depend on your app's AJAX endpoints)
        page.execute_script("
          fetch('/journal_entries', {
            method: 'GET',
            headers: {
              'X-Requested-With': 'XMLHttpRequest',
              'Accept': 'application/json'
            }
          }).then(response => {
            window.ajaxResponse = response;
          });
        ")
        
        # Check that the response indicates authentication is required
        response_status = page.evaluate_script('window.ajaxResponse.status')
        expect(response_status).to eq(401)
      end
    end
  end
  
  # Integration tests showing interaction between rememberable and timeoutable
  describe 'Integration with rememberable' do
    it 'remember token overrides session timeout' do
      # Sign in with remember me
      complete_sign_in(
        email: user.email,
        password: user.password,
        remember_me: true
      )
      expect_sign_in_success
      
      # Fast forward well beyond session timeout
      travel_to(30.minutes.from_now) do
        visit journal_entries_path
        
        # Should be authenticated via remember token, not session
        expect(current_path).to eq(journal_entries_path)
        expect_user_to_be_signed_in
      end
    end
    
    it 'clearing remember token allows session timeout to work' do
      # Sign in with remember me
      complete_sign_in(
        email: user.email,
        password: user.password,
        remember_me: true
      )
      expect_sign_in_success
      
      # Manually clear remember token (simulating user clearing cookies)
      page.driver.browser.manage.delete_cookie('remember_user_token')
      
      # Fast forward beyond session timeout
      travel_to(10.minutes.from_now) do
        visit journal_entries_path
        
        # Should be timed out since no remember token and session expired
        expect(current_path).to eq("/users/sign_in")
        expect(page).to have_content("Your session expired")
      end
    end
  end
  
  # Helper method for time travel (requires Rails 6+ or timecop gem)
  def travel_to(time)
    if defined?(Timecop)
      Timecop.travel(time) { yield }
    elsif Time.respond_to?(:travel_to)
      # Rails 6+ built-in time helpers
      Time.travel_to(time) { yield }
    else
      # Fallback for older Rails versions - would need to mock Time/DateTime
      skip "Time travel not available in this Rails version"
    end
  end
end

# Additional configuration notes for implementing timeoutable:
#
# 1. User model changes (app/models/user.rb):
#    class User < ApplicationRecord
#      devise :database_authenticatable, :registerable,
#             :recoverable, :rememberable, :validatable, :timeoutable
#    end
#
# 2. Devise initializer changes (config/initializers/devise.rb):
#    config.timeout_in = 5.minutes  # Adjust as needed
#
# 3. Optional: Custom timeout message in views
#    You can customize the timeout message by overriding Devise views
#    and checking for the timeout flash message
#
# 4. JavaScript timeout warning (optional enhancement):
#    You could implement a JavaScript timer that warns users before
#    their session expires and offers to extend the session
#
# 5. Database considerations:
#    Timeoutable doesn't require additional database columns.
#    It works by checking the last request time stored in the session.
#
# 6. Testing considerations:
#    - Use time travel helpers (Timecop gem or Rails 6+ travel_to)
#    - Test both regular requests and AJAX requests
#    - Test interaction with remember_me functionality
#    - Test timeout message display
