module SignupHelpers
  # Page object helper methods for signup actions
  
  def visit_signup_page
    visit "/signup"
  end
  
  def fill_in_signup_form(email:, password:, password_confirmation: nil)
    fill_in "Email", with: email
    fill_in "Password", with: password
    fill_in "Password confirmation", with: password_confirmation || password
  end
  
  def submit_signup_form
    click_button "Create Account"
  end
  
  def complete_signup(email:, password:, password_confirmation: nil)
    visit_signup_page
    fill_in_signup_form(
      email: email,
      password: password,
      password_confirmation: password_confirmation
    )
    submit_signup_form
  end
  
  # Helper methods for form field interactions
  def fill_in_email(email)
    fill_in "Email", with: email
  end
  
  def fill_in_password(password)
    fill_in "Password", with: password
  end
  
  def fill_in_password_confirmation(password_confirmation)
    fill_in "Password confirmation", with: password_confirmation
  end
  
  # Validation helpers
  def expect_signup_success
    # Wait for the success flash message to appear (indicates successful signup and redirect)
    expect(page).to have_content("Welcome! You have signed up successfully")
    
    # Expect redirection to root path
    expect(current_path).to eq("/")
    
    # Expect user-specific content on the home page
    expect(page).to have_content("Hello,")
    expect(page).to have_content("@example.com") # Since we use test emails with example.com
    expect(page).to have_link("View Entries")
    expect(page).to have_link("Create Entry")
    expect(page).to have_link("Edit Profile")
    expect(page).to have_link("Sign Out")
  end
  
  def expect_signup_success_with_user_count_check(expected_email = nil)
    # Store initial user count
    initial_count = User.count
    
    # Expect user count to increase by 1
    expect(User.count).to eq(initial_count + 1)
    
    # Call standard success expectations
    expect_signup_success
    
    # If email provided, check that specific email appears
    if expected_email
      expect(page).to have_content(expected_email)
    end
  end
  
  def expect_signup_error(message = nil)
    if message
      expect(page).to have_content(message)
    else
      expect(page).to have_css(".alert-danger, .error_explanation, .field_with_errors")
    end
  end
  
  def expect_to_be_on_signup_page
    expect(page).to have_content("Create your account")
    expect(current_path).to eq("/users/sign_up")
  end
end

# Include the helper module in system specs
RSpec.configure do |config|
  config.include SignupHelpers, type: :system
end

