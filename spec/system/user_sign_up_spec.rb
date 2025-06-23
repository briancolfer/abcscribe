require "rails_helper"

RSpec.describe "User sign up", type: :system do
  # The signup_helpers and shared context are automatically included
  
  describe "successful signup" do
    it "allows a user to sign up with valid credentials using helper method" do
      complete_signup(
        email: valid_email,
        password: valid_password,
        password_confirmation: valid_password_confirmation
      )
      
      expect_signup_success
    end
    
    it "successfully completes signup flow with all requirements" do
      # Use unique email from shared context
      test_email = unique_email
      initial_count = User.count
      
      complete_signup(
        email: test_email,
        password: valid_password,
        password_confirmation: valid_password_confirmation
      )
      
      expect_signup_success_with_user_count_check(test_email)
      
      # Verify user count increased by 1
      expect(User.count).to eq(initial_count + 1)
      
      # Verify the created user exists in database
      created_user = User.find_by(email: test_email)
      expect(created_user).to be_present
      expect(created_user.email).to eq(test_email)
    end
    
    it "allows a user to sign up using individual helper methods" do
      visit_signup_page
      expect_to_be_on_signup_page
      
      fill_in_email(unique_email)
      fill_in_password(valid_password)
      fill_in_password_confirmation(valid_password_confirmation)
      submit_signup_form
      
      expect_signup_success
    end
    
    it "can use let block attributes directly" do
      complete_signup(**valid_user_attributes)
      expect_signup_success
    end
  end
  
  describe "validation errors" do
    it "shows error for invalid email" do
      visit_signup_page
      
      # Use JavaScript to set an invalid email that bypasses HTML5 validation
      page.execute_script("document.getElementById('user_email').type = 'text'")
      fill_in_signup_form(
        email: invalid_email,
        password: valid_password,
        password_confirmation: valid_password_confirmation
      )
      
      submit_signup_form
      expect_signup_error("Email is invalid")
    end
    
    it "shows error for blank email" do
      complete_signup(**user_with_blank_email)
      expect_signup_error("Email can't be blank")
    end
    
    it "shows error for missing password" do
      complete_signup(
        email: valid_email,
        password: blank_password,
        password_confirmation: blank_password
      )
      expect_signup_error("Password can't be blank")
    end

    it "shows error for short password" do
      complete_signup(**user_with_short_password)
      expect_signup_error("Password is too short")
    end
    
    it "shows error for mismatched password confirmation" do
      complete_signup(**user_with_mismatched_password)
      expect_signup_error("Password confirmation doesn't match Password")
    end
    
    it "shows error for duplicate email" do
      # Pre-create a user with the duplicate email from shared context
      create(:user, email: duplicate_email)
      
      # Attempt to sign up with the same email
      complete_signup(**user_with_duplicate_email)
      expect_signup_error("Email has already been taken")
    end
  end
  
  describe "form interaction" do
    before do
      visit_signup_page
    end
    
    it "can fill form step by step" do
      fill_in_signup_form(
        email: valid_email,
        password: valid_password,
        password_confirmation: valid_password_confirmation
      )
      
      submit_signup_form
      expect_signup_success
    end
  end
  
  describe "form field presence and accessibility" do
    before do
      visit_signup_page
    end
    
    it "displays email label and input field with correct autocomplete attribute" do
      expect(page).to have_css("label", text: "Email")
      expect(page).to have_field("Email", type: "email")
      expect(page).to have_css("input[type='email'][autocomplete='email']")
    end
    
    it "displays password label and input field with correct autocomplete attribute" do
      expect(page).to have_css("label", text: "Password")
      expect(page).to have_field("Password", type: "password")
      expect(page).to have_css("input[type='password'][autocomplete='new-password']", count: 2)
    end
    
    it "displays password confirmation label and input field with correct autocomplete attribute" do
      expect(page).to have_css("label", text: "Password confirmation")
      expect(page).to have_field("Password confirmation", type: "password")
    end
    
    it "displays submit button with accessible text 'Create Account'" do
      expect(page).to have_button("Create Account")
      expect(page).to have_css("input[type='submit'][value='Create Account']")
    end
    
    it "has all required form elements present and accessible" do
      # Check that all labels are present
      expect(page).to have_css("label", text: "Email")
      expect(page).to have_css("label", text: "Password")
      expect(page).to have_css("label", text: "Password confirmation")
      
      # Check that all input fields are present with correct types
      expect(page).to have_field("Email", type: "email")
      expect(page).to have_field("Password", type: "password")
      expect(page).to have_field("Password confirmation", type: "password")
      
      # Check autocomplete attributes
      expect(page).to have_css("input[name='user[email]'][autocomplete='email']")
      expect(page).to have_css("input[name='user[password]'][autocomplete='new-password']")
      expect(page).to have_css("input[name='user[password_confirmation]'][autocomplete='new-password']")
      
      # Check submit button
      expect(page).to have_button("Create Account")
    end
  end
end

