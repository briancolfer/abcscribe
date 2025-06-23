require 'rails_helper'

RSpec.describe 'User Authentication', type: :system do
  # The authentication test data shared context is automatically included
  # The authentication helpers module is automatically included
  
  describe 'Sign in' do
    context 'with valid credentials' do
      before do
        # Create a user using the shared context data
        valid_user # This creates the user with valid_email and valid_password
      end
      
      it 'allows user to sign in successfully' do
        complete_sign_in(
          email: valid_email,
          password: valid_password
        )
        
        expect_sign_in_success
        expect_sign_in_success_with_email(valid_email)
      end
      
      it 'allows user to sign in with remember me' do
        visit_sign_in_page
        fill_in_sign_in_credentials(
          email: valid_email,
          password: valid_password,
          remember_me: true
        )
        submit_sign_in_form
        
        expect_sign_in_success
      end
    end
    
    context 'with invalid credentials' do
      before do
        valid_user # Create a user first
      end
      
      it 'shows error for wrong password' do
        complete_sign_in(
          email: valid_email,
          password: invalid_password
        )
        
        expect_invalid_credentials_error
      end
      
      it 'shows error for nonexistent user' do
        complete_sign_in(
          email: nonexistent_email,
          password: valid_password
        )
        
        expect_invalid_credentials_error
      end
      
      it 'shows error for blank email' do
        visit_sign_in_page
        fill_in_sign_in_credentials(**blank_email_credentials)
        submit_sign_in_form
        
        expect_sign_in_error
      end
      
      it 'shows error for blank password' do
        visit_sign_in_page
        fill_in_sign_in_credentials(**blank_password_credentials)
        submit_sign_in_form
        
        expect_sign_in_error
      end
    end
  end
  
  describe 'Sign out' do
    before do
      # Use programmatic sign in for test setup
      sign_in_user(valid_user)
    end
    
    it 'allows user to sign out successfully' do
      visit root_path
      expect_user_to_be_signed_in
      
      sign_out_user
      expect_sign_out_success
      expect_user_to_be_signed_out
    end
  end
  
  describe 'Authentication protection' do
    it 'redirects unauthenticated users to sign in page' do
      visit_protected_page
      expect_redirect_to_sign_in
    end
    
    it 'allows authenticated users to access protected pages' do
      sign_in_user(valid_user)
      visit_protected_page
      
      expect(current_path).to eq(journal_entries_path)
      expect(page).not_to have_content("You need to sign in")
    end
  end
  
  describe 'Navigation states' do
    it 'shows appropriate links when signed out' do
      visit root_path
      expect_user_to_be_signed_out
    end
    
    it 'shows appropriate links when signed in' do
      sign_in_user(valid_user)
      visit root_path
      expect_user_to_be_signed_in
    end
  end
end
