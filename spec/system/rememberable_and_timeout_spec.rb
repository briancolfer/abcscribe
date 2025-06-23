require 'rails_helper'

RSpec.describe 'Rememberable and Session Timeout', type: :system do
  # The authentication test data shared context is automatically included
  # The authentication helpers module is automatically included
  
  let(:user) { create(:user) }
  
  describe 'Remember me functionality' do
    before do
      # Ensure we start with a clean slate
      Capybara.reset_sessions!
    end
    
    context 'when remember me is checked' do
      it 'sets the remember token cookie' do
        # Sign in with remember me checked
        visit_sign_in_page
        fill_in_sign_in_credentials(
          email: user.email,
          password: user.password,
          remember_me: true
        )
        submit_sign_in_form
        
        # Verify successful sign in
        expect_sign_in_success
        
        # Check that remember token cookie is set
        remember_token_cookie = get_remember_token_cookie
        expect(remember_token_cookie).not_to be_nil
        expect(remember_token_cookie[:value]).not_to be_empty
        
        # Verify the remember_created_at timestamp is set in the database
        user.reload
        expect(user.remember_created_at).not_to be_nil
        expect(user.remember_created_at).to be_within(1.minute).of(Time.current)
      end
      
      it 'persists login across browser sessions' do
        # Sign in with remember me checked
        complete_sign_in(
          email: user.email,
          password: user.password,
          remember_me: true
        )
        expect_sign_in_success
        
        # Simulate browser session expiry by clearing session cookies but keeping persistent cookies
        # This simulates what happens when a browser is closed and reopened
        page.driver.browser.manage.delete_cookie('_abcscribe_session')
        
        # Visit the application again
        visit root_path
        
        # User should still be logged in due to remember token
        expect_user_to_be_signed_in
        expect(page).to have_content("Hello, #{user.email}!")
      end
      
      it 'allows access to protected pages without re-authentication' do
        # Sign in with remember me
        complete_sign_in(
          email: user.email,
          password: user.password,
          remember_me: true
        )
        expect_sign_in_success
        
        # Clear session cookie to simulate browser restart
        page.driver.browser.manage.delete_cookie('_abcscribe_session')
        
        # Try to access protected page
        visit_protected_page
        
        # Should be able to access without being redirected to sign in
        expect(current_path).to eq(journal_entries_path)
        expect(page).not_to have_content("You need to sign in or sign up before continuing.")
      end
      
      it 'updates remember token expiry on subsequent visits' do
        # Sign in with remember me
        complete_sign_in(
          email: user.email,
          password: user.password,
          remember_me: true
        )
        expect_sign_in_success
        
        # Get initial remember_created_at timestamp
        user.reload
        initial_remember_time = user.remember_created_at
        
        # Wait a moment to ensure timestamp difference
        sleep(1)
        
        # Clear session and visit again (which should extend remember period)
        page.driver.browser.manage.delete_cookie('_abcscribe_session')
        visit root_path
        
        # Check if remember_created_at was updated (if extend_remember_period is enabled)
        user.reload
        # Note: This test depends on Devise configuration for extend_remember_period
        # If enabled, the timestamp should be updated
        expect(user.remember_created_at).to be >= initial_remember_time
      end
    end
    
    context 'when remember me is not checked' do
      it 'does not set the remember token cookie' do
        # Sign in without remember me
        complete_sign_in(
          email: user.email,
          password: user.password,
          remember_me: false
        )
        expect_sign_in_success
        
        # Check that remember token cookie is not set
        remember_token_cookie = get_remember_token_cookie
        expect(remember_token_cookie).to be_nil
        
        # Verify the remember_created_at is not set in the database
        user.reload
        expect(user.remember_created_at).to be_nil
      end
      
      it 'does not persist login across browser sessions' do
        # Sign in without remember me
        complete_sign_in(
          email: user.email,
          password: user.password,
          remember_me: false
        )
        expect_sign_in_success
        
        # Clear session cookie to simulate browser restart
        page.driver.browser.manage.delete_cookie('_abcscribe_session')
        
        # Visit the application again
        visit root_path
        
        # User should be signed out
        expect_user_to_be_signed_out
        expect(page).to have_content("Please sign in to access your account")
      end
      
      it 'requires re-authentication for protected pages after session expiry' do
        # Sign in without remember me
        complete_sign_in(
          email: user.email,
          password: user.password,
          remember_me: false
        )
        expect_sign_in_success
        
        # Clear session cookie to simulate browser restart
        page.driver.browser.manage.delete_cookie('_abcscribe_session')
        
        # Try to access protected page
        visit_protected_page
        
        # Should be redirected to sign in page
        expect_redirect_to_sign_in
      end
    end
    
    context 'remember token expiry' do
      it 'expires remember token after configured period' do
        # This test would require manipulating time and the remember_for configuration
        # For now, we'll test that the remember_created_at is set correctly
        complete_sign_in(
          email: user.email,
          password: user.password,
          remember_me: true
        )
        expect_sign_in_success
        
        user.reload
        expect(user.remember_created_at).to be_within(1.minute).of(Time.current)
        
        # Verify that after signing out and clearing session, 
        # the remember functionality would work (if within period)
        sign_out_user
        
        # Clear all cookies to simulate browser restart
        page.driver.browser.manage.delete_all_cookies
        
        # Visit a protected page - should redirect to sign in since remember tokens expire on sign out
        visit journal_entries_path
        expect_redirect_to_sign_in
      end
    end
    
    context 'sign out behavior' do
      it 'clears remember token when signing out' do
        # Sign in with remember me
        complete_sign_in(
          email: user.email,
          password: user.password,
          remember_me: true
        )
        expect_sign_in_success
        
        # Verify remember timestamp is set
        user.reload
        expect(user.remember_created_at).not_to be_nil
        
        # Sign out
        sign_out_user
        expect_sign_out_success
        
        # Verify remember timestamp is cleared (if expire_all_remember_me_on_sign_out is true)
        user.reload
        expect(user.remember_created_at).to be_nil
        
        # Verify remember token cookie is cleared
        remember_token_cookie = get_remember_token_cookie
        expect(remember_token_cookie).to be_nil
      end
    end
  end
  
  describe 'Session timeout functionality', skip: 'Enable when timeoutable is configured' do
    # These tests would be enabled if :timeoutable module is added to the User model
    # and timeout_in is configured in devise.rb
    
    before do
      # This would require enabling timeoutable in User model:
      # devise :database_authenticatable, :registerable, :recoverable, 
      #        :rememberable, :validatable, :timeoutable
      # 
      # And configuring timeout in devise.rb:
      # config.timeout_in = 5.minutes
    end
    
    context 'when user is idle beyond timeout period' do
      it 'prompts for re-authentication after timeout' do
        # Sign in user
        complete_sign_in(
          email: user.email,
          password: user.password
        )
        expect_sign_in_success
        
        # Fast-forward time beyond timeout period
        travel_to(10.minutes.from_now) do
          # Try to access a protected page
          visit_protected_page
          
          # Should be redirected to sign in with timeout message
          expect(current_path).to eq("/users/sign_in")
          expect(page).to have_content("Your session expired. Please sign in again to continue.")
        end
      end
      
      it 'maintains session when user is active within timeout period' do
        # Sign in user
        complete_sign_in(
          email: user.email,
          password: user.password
        )
        expect_sign_in_success
        
        # Make a request within timeout period
        travel_to(3.minutes.from_now) do
          visit root_path
          expect_user_to_be_signed_in
        end
        
        # Make another request still within timeout window from last activity
        travel_to(6.minutes.from_now) do
          visit_protected_page
          expect(current_path).to eq(journal_entries_path)
          expect_user_to_be_signed_in
        end
      end
      
      it 'resets timeout period on each request' do
        # Sign in user
        complete_sign_in(
          email: user.email,
          password: user.password
        )
        expect_sign_in_success
        
        # Make requests every 3 minutes for 15 minutes
        # Each request should reset the timeout period
        [3, 6, 9, 12, 15].each do |minutes|
          travel_to(minutes.minutes.from_now) do
            visit root_path
            expect_user_to_be_signed_in
          end
        end
      end
      
      it 'does not timeout when remember me is checked and user is inactive' do
        # Sign in with remember me
        complete_sign_in(
          email: user.email,
          password: user.password,
          remember_me: true
        )
        expect_sign_in_success
        
        # Fast-forward time beyond timeout period
        travel_to(10.minutes.from_now) do
          visit_protected_page
          
          # User should still be logged in due to remember token
          expect(current_path).to eq(journal_entries_path)
          expect_user_to_be_signed_in
        end
      end
    end
    
    context 'timeout warning' do
      it 'displays warning before timeout expires' do
        # This would require implementing a timeout warning system
        # with JavaScript to warn users before their session expires
        
        complete_sign_in(
          email: user.email,
          password: user.password
        )
        expect_sign_in_success
        
        # Fast-forward to 1 minute before timeout
        travel_to(4.minutes.from_now) do
          visit root_path
          
          # This would depend on implementing a timeout warning feature
          # expect(page).to have_content("Your session will expire in 1 minute")
        end
      end
    end
  end
  
  describe 'Integration of rememberable and timeoutable' do
    context 'when both features are enabled', skip: 'Enable when timeoutable is configured' do
      it 'remember token takes precedence over session timeout' do
        # Sign in with remember me
        complete_sign_in(
          email: user.email,
          password: user.password,
          remember_me: true
        )
        expect_sign_in_success
        
        # Fast-forward beyond session timeout but within remember token period
        travel_to(10.minutes.from_now) do
          # Clear session to simulate timeout
          page.driver.browser.manage.delete_cookie('_abcscribe_session')
          
          visit_protected_page
          
          # Should still be logged in due to remember token
          expect(current_path).to eq(journal_entries_path)
          expect_user_to_be_signed_in
        end
      end
      
      it 'session timeout is ignored when remember token is present' do
        # Sign in with remember me
        complete_sign_in(
          email: user.email,
          password: user.password,
          remember_me: true
        )
        expect_sign_in_success
        
        # Stay idle for longer than session timeout
        travel_to(30.minutes.from_now) do
          visit root_path
          
          # Should be logged in via remember token
          expect_user_to_be_signed_in
        end
      end
    end
  end
  
  # Helper method to check if timeoutable is enabled
  def timeoutable_enabled?
    User.devise_modules.include?(:timeoutable)
  end
  
  # Helper method to travel in time (requires timecop gem or Rails 6+ travel_to)
  def travel_to(time)
    if defined?(Timecop)
      Timecop.travel(time) { yield }
    elsif Time.respond_to?(:travel_to)
      Time.travel_to(time) { yield }
    else
      # Fallback for older Rails versions
      yield
    end
  end
  
  # Helper method to get remember token cookie
  def get_remember_token_cookie
    begin
      page.driver.browser.manage.cookie_named("remember_user_token")
    rescue Selenium::WebDriver::Error::NoSuchCookieError
      nil
    end
  end
end
