module SessionHelpers
  def sign_in(user)
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Log In"
  end
end

RSpec.configure do |config|
  config.include SessionHelpers, type: :feature
end

