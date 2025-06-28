require 'rails_helper'

RSpec.describe 'User Sign In', type: :system do
  # The authentication test data shared context is automatically included
  # The authentication helpers module is automatically included
  
  describe 'successful sign-in' do
    before do
      # Create a user using the shared context data
      valid_user # This creates the user with valid_email and valid_password
    end
    
    it 'allows user to sign in successfully using helper methods' do
      complete_sign_in(
        email: valid_email,
        password: valid_password
      )
      
      expect_sign_in_success
      expect_sign_in_success_with_email(valid_email)
    end
    
    it 'shows success message and user content after successful sign-in' do
      complete_sign_in(
        email: valid_email,
        password: valid_password
      )
      
      # Verify sign-in success message appears
      expect(page).to have_content('Signed in successfully')
      # Verify user content is displayed
      expect(page).to have_content("Hello: #{valid_email}")
    end
    
    it 'displays user-specific navigation after successful sign-in' do
      complete_sign_in(
        email: valid_email,
        password: valid_password
      )
      
      # Check presence of user-specific navigation elements
      expect(page).to have_content("Hello: #{valid_email}")
      expect(page).to have_link('View Entries')
      expect(page).to have_link('Create Entry')
      expect(page).to have_link('Edit Profile')
      expect(page).to have_button('Sign Out')
      
      # Verify that unauthenticated navigation is not present
      expect(page).not_to have_link('Sign In')
      expect(page).not_to have_link('Sign Up')
    end
    
    it 'allows user to sign in with remember me option' do
      visit_sign_in_page
      fill_in_sign_in_credentials(
        email: valid_email,
        password: valid_password,
        remember_me: true
      )
      submit_sign_in_form
      
      expect_sign_in_success
    end
    
    it 'allows user to sign in using individual helper methods' do
      visit_sign_in_page
      fill_in_email(valid_email)
      fill_in_password(valid_password)
      submit_sign_in_form
      
      expect_sign_in_success
    end
  end
  
  describe 'sign-in failure' do
    before do
      valid_user # Create a user first
    end
    
    it 'shows error message for wrong password' do
      complete_sign_in(
        email: valid_email,
        password: invalid_password
      )
      
      expect_invalid_credentials_error
      expect(page).to have_content('Invalid Email or password.')
    end
    
    it 'shows error message for unregistered email' do
      complete_sign_in(
        email: nonexistent_email,
        password: valid_password
      )
      
      expect_invalid_credentials_error
      # Note: Exact error message may vary, but we should stay on sign-in page
    end
    
    it 'shows error message for blank email' do
      visit_sign_in_page
      fill_in_sign_in_credentials(**blank_email_credentials)
      submit_sign_in_form
      
      expect_sign_in_error
      expect(current_path).to eq('/users/sign_in')
    end
    
    it 'shows error message for blank password' do
      visit_sign_in_page
      fill_in_sign_in_credentials(**blank_password_credentials)
      submit_sign_in_form
      
      expect_sign_in_error
      expect(current_path).to eq('/users/sign_in')
    end
    
    it 'shows error message for invalid email format' do
      complete_sign_in(
        email: invalid_email,
        password: valid_password
      )
      
      expect_sign_in_error
      expect(current_path).to eq('/users/sign_in')
    end
    
    it 'remains on sign-in page after failed attempt' do
      complete_sign_in(
        email: valid_email,
        password: invalid_password
      )
      
      expect(current_path).to eq('/users/sign_in')
      expect(page).to have_content('Sign in to your account')
    end
  end
  
  describe 'successful sign-out' do
    before do
      # Use programmatic sign in for test setup
      sign_in_user(valid_user)
    end
    
    it 'allows user to sign out successfully using helper methods' do
      visit root_path
      expect_user_to_be_signed_in
      
      sign_out_user
      expect_sign_out_success
    end
    
    it 'redirects to root path after sign-out' do
      visit root_path
      sign_out_user
      
      # Verify redirection to root
      expect(current_path).to eq('/')
    end
    
    it 'displays appropriate navigation after sign-out' do
      visit root_path
      sign_out_user
      
      # Check that signed-out navigation is present
      expect(page).to have_content('Please sign in to access your account')
      expect(page).to have_link('Sign In')
      expect(page).to have_link('Sign Up')
      
      # Verify that user-specific navigation is not present
      expect(page).not_to have_content('Hello:')
      expect(page).not_to have_link('View Entries')
      expect(page).not_to have_link('Create Entry')
      expect(page).not_to have_link('Edit Profile')
      expect(page).not_to have_button('Sign Out')
    end
    
    it 'verifies user state changes from signed-in to signed-out' do
      visit root_path
      
      # Verify initially signed in
      expect_user_to_be_signed_in
      
      # Sign out
      sign_out_user
      
      # Verify now signed out
      expect_user_to_be_signed_out
    end
    
    it 'prevents access to protected pages after sign-out' do
      visit root_path
      sign_out_user
      
      # Try to visit a protected page
      visit_protected_page
      expect_redirect_to_sign_in
    end
  end
  
  describe 'navigation state verification' do
    it 'shows appropriate links when user is signed out' do
      visit root_path
      expect_user_to_be_signed_out
      
      expect(page).to have_link('Sign In')
      expect(page).to have_link('Sign Up')
      expect(page).not_to have_button('Sign Out')
    end
    
    it 'shows appropriate links when user is signed in' do
      sign_in_user(valid_user)
      visit root_path
      expect_user_to_be_signed_in
      
      expect(page).to have_button('Sign Out')
      expect(page).not_to have_link('Sign In')
      expect(page).not_to have_link('Sign Up')
    end
  end
  
  describe 'authentication flow integration' do
    it 'completes full sign-in and sign-out cycle' do
      # Start signed out
      visit root_path
      expect_user_to_be_signed_out
      
      # Sign in
      complete_sign_in(
        email: valid_user.email,
        password: valid_password
      )
      expect_sign_in_success
      
      # Verify signed in state
      expect_user_to_be_signed_in
      
      # Sign out
      sign_out_user
      expect_sign_out_success
      
      # Verify signed out state
      expect_user_to_be_signed_out
    end
    
    it 'maintains session state across page visits when signed in' do
      sign_in_user(valid_user)
      
      # Visit root and verify signed in
      visit root_path
      expect_user_to_be_signed_in
      
      # Visit another page and verify user can access protected content
      visit_protected_page
      expect(current_path).to eq(journal_entries_path)
      # The user should be able to access this page without being redirected
      expect(page).not_to have_content("You need to sign in")
    end
  end
end
