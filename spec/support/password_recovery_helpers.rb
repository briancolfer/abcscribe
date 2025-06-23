module PasswordRecoveryHelpers
  # Page object helper methods for password recovery actions
  
  def visit_forgot_password_page
    visit new_user_password_path
  end
  
  def visit_reset_password_page(token)
    visit edit_user_password_path(reset_password_token: token)
  end
  
  # Form filling helpers
  def fill_in_forgot_password_form(email:)
    fill_in 'Email', with: email
  end
  
  def submit_forgot_password_form
    click_button 'Send me reset password instructions'
  end
  
  def complete_forgot_password_request(email:)
    visit_forgot_password_page
    fill_in_forgot_password_form(email: email)
    submit_forgot_password_form
  end
  
  def fill_in_reset_password_form(password:, password_confirmation: nil)
    fill_in 'New password', with: password
    fill_in 'Confirm new password', with: password_confirmation || password
  end
  
  def submit_reset_password_form
    click_button 'Change my password'
  end
  
  def complete_password_reset(token:, password:, password_confirmation: nil)
    visit_reset_password_page(token)
    fill_in_reset_password_form(
      password: password,
      password_confirmation: password_confirmation
    )
    submit_reset_password_form
  end
  
  # Expectation helpers
  def expect_forgot_password_success
    expect(page).to have_content('You will receive an email with instructions on how to reset your password in a few minutes.')
  end
  
  def expect_forgot_password_error(message = nil)
    if message
      expect(page).to have_content(message)
    else
      expect(page).to have_css('.field_with_errors, .alert-danger')
    end
    expect(current_path).to eq(new_user_password_path)
  end
  
  def expect_password_reset_success
    expect(page).to have_content('Your password has been changed successfully. You are now signed in.')
    expect(current_path).to eq(root_path)
  end
  
  def expect_password_reset_error(message = nil)
    if message
      expect(page).to have_content(message)
    else
      expect(page).to have_css('.field_with_errors, .alert-danger')
    end
  end
  
  def expect_to_be_on_forgot_password_page
    expect(page).to have_content('Forgot your password?')
    expect(current_path).to eq(new_user_password_path)
  end
  
  def expect_to_be_on_reset_password_page
    expect(page).to have_content('Change your password')
    expect(current_path).to match(/\/users\/password\/edit/)
  end
  
  # Helper methods for testing
  def generate_reset_password_token_for(user)
    raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
    user.update!(
      reset_password_token: hashed_token,
      reset_password_sent_at: Time.current
    )
    raw_token
  end
  
  def expect_reset_token_to_be_set(user)
    user.reload
    expect(user.reset_password_token).to be_present
    expect(user.reset_password_sent_at).to be_present
    expect(user.reset_password_sent_at).to be_within(1.minute).of(Time.current)
  end
  
  def expect_reset_token_to_be_cleared(user)
    user.reload
    expect(user.reset_password_token).to be_nil
    expect(user.reset_password_sent_at).to be_nil
  end
  
  def expect_password_reset_email_sent(email)
    expect(ActionMailer::Base.deliveries.count).to be > 0
    
    email_sent = ActionMailer::Base.deliveries.last
    expect(email_sent.to).to include(email)
    expect(email_sent.subject).to include('Reset password instructions')
    expect(email_sent.body.to_s).to include('Change my password')
  end
  
  def expect_no_password_reset_email_sent
    expect(ActionMailer::Base.deliveries.count).to eq(0)
  end
  
  def clear_emails
    ActionMailer::Base.deliveries.clear
  end
end

# Include the helper module in system specs
RSpec.configure do |config|
  config.include PasswordRecoveryHelpers, type: :system
end
