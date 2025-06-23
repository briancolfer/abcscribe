module AuthenticationHelpers
  # Page object helper methods for authentication actions
  
  def visit_sign_in_page
    visit "/users/sign_in"
  end
  
  def fill_in_sign_in_credentials(email:, password:, remember_me: false)
    fill_in "Email", with: email
    fill_in "Password", with: password
    check "Remember me" if remember_me
  end
  
  def submit_sign_in_form
    click_button "Sign In"
  end
  
  def complete_sign_in(email:, password:, remember_me: false)
    visit_sign_in_page
    # Wait for page to fully load
    expect(page).to have_content("Sign in to your account", wait: 5)
    
    fill_in_sign_in_credentials(
      email: email,
      password: password,
      remember_me: remember_me
    )
    submit_sign_in_form
    
    # Wait for redirect to complete
    sleep(0.5)
  end
  
  # Individual form field helper methods
  def fill_in_email(email)
    fill_in "Email", with: email
  end
  
  def fill_in_password(password)
    fill_in "Password", with: password
  end
  
  def check_remember_me
    check "Remember me"
  end
  
  def uncheck_remember_me
    uncheck "Remember me"
  end
  
  # Validation helpers for sign-in success/error states
  def expect_sign_in_success
    # Wait for and check either success message or authenticated state
    # Note: With Turbo, redirects might not complete immediately
    begin
      expect(page).to have_content("Signed in successfully", wait: 5)
    rescue RSpec::Expectations::ExpectationNotMetError
      # If no success message, check for authenticated state
      expect(page).to have_content("Hello,", wait: 5)
    end
    
    # Wait for user-specific content on the home page
    expect(page).to have_content("Hello,", wait: 5)
    expect(page).to have_link("View Entries", wait: 5)
    expect(page).to have_link("Create Entry", wait: 5)
    expect(page).to have_link("Edit Profile", wait: 5)
    expect(page).to have_button("Sign Out", wait: 5)
    
    # Should not show sign-in/sign-up links
    expect(page).not_to have_link("Sign In")
    expect(page).not_to have_link("Sign Up")
  end
  
  def expect_sign_in_success_with_email(expected_email)
    expect_sign_in_success
    
    # Check that the specific email appears on the page
    expect(page).to have_content(expected_email)
  end
  
  def expect_sign_in_error(message = nil)
    # Should remain on sign-in page
    expect(current_path).to eq("/users/sign_in")
    expect(page).to have_content("Sign in to your account")
    
    if message
      expect(page).to have_content(message)
    end
    # Note: Error styling might vary, so checking for specific message is more reliable
  end
  
  def expect_invalid_credentials_error
    # Should remain on sign-in page
    expect(current_path).to eq("/users/sign_in")
    expect(page).to have_content("Sign in to your account")
    # Invalid credentials might be shown as alert flash or inline error
    expect(page).to have_content("Invalid").or have_content("incorrect").or have_content("password")
  end
  
  def expect_to_be_on_sign_in_page
    expect(page).to have_content("Sign in to your account")
    expect(page).to have_content("Continue tracking your behavioral patterns")
    expect(current_path).to eq("/users/sign_in")
  end
  
  # Sign out helper methods
  def sign_out_user
    # Handle Turbo-powered sign-out button with async behavior
    click_button "Sign Out"
    
    # Wait for the sign-out to complete by waiting for user-specific content to disappear
    # This is more reliable than waiting for specific text that might not appear
    expect(page).not_to have_content("Hello,", wait: 10)
    
    # Also ensure we're back at root and not showing sign-out button anymore
    expect(page).not_to have_button("Sign Out", wait: 5)
  end
  
  def expect_sign_out_success
    # Should redirect to home page but show signed-out state
    expect(current_path).to eq("/")
    expect(page).to have_content("Please sign in to access your account")
    expect(page).to have_link("Sign In")
    expect(page).to have_link("Sign Up")
    
    # Should not show signed-in user content
    expect(page).not_to have_content("Hello,")
    expect(page).not_to have_link("View Entries")
    expect(page).not_to have_link("Create Entry")
    expect(page).not_to have_link("Edit Profile")
    expect(page).not_to have_link("Sign Out")
  end
  
  # Programmatic authentication helpers (for test setup)
  def sign_in_user(user)
    login_as user, scope: :user
  end
  
  def sign_out_programmatically
    logout(:user)
  end
  
  # Authentication state checking helpers
  def expect_user_to_be_signed_in
    expect(page).to have_button("Sign Out")
    expect(page).not_to have_link("Sign In")
  end
  
  def expect_user_to_be_signed_out
    expect(page).to have_link("Sign In")
    expect(page).not_to have_button("Sign Out")
  end
  
  # Navigation helpers for authenticated vs unauthenticated states
  def visit_protected_page
    visit journal_entries_path
  end
  
  def expect_redirect_to_sign_in
    expect(current_path).to eq("/users/sign_in")
    expect(page).to have_content("You need to sign in or sign up before continuing.")
  end
end

# Include the helper module in system specs
RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :system
end
