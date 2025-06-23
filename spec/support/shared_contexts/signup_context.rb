RSpec.shared_context "signup test data" do
  # Valid user attributes
  let(:valid_email) { "user@example.com" }
  let(:valid_password) { "password123" }
  let(:valid_password_confirmation) { valid_password }
  
  # Valid user attributes hash
  let(:valid_user_attributes) do
    {
      email: valid_email,
      password: valid_password,
      password_confirmation: valid_password_confirmation
    }
  end
  
  # Invalid user attributes for various test scenarios
  let(:invalid_email) { "invalid-email" }
  let(:blank_email) { "" }
  let(:blank_password) { "" }
  let(:short_password) { "123" }
  let(:mismatched_password_confirmation) { "different_password" }
  
  # Invalid user attributes collections
  let(:user_with_invalid_email) do
    {
      email: invalid_email,
      password: valid_password,
      password_confirmation: valid_password_confirmation
    }
  end
  
  let(:user_with_blank_email) do
    {
      email: blank_email,
      password: valid_password,
      password_confirmation: valid_password_confirmation
    }
  end
  
  let(:user_with_short_password) do
    {
      email: valid_email,
      password: short_password,
      password_confirmation: short_password
    }
  end
  
  let(:user_with_mismatched_password) do
    {
      email: valid_email,
      password: valid_password,
      password_confirmation: mismatched_password_confirmation
    }
  end
  
  # Helper for generating unique emails
  let(:unique_email) { "user#{SecureRandom.hex(4)}@example.com" }
  
  # Duplicate email scenario
  let(:duplicate_email) { "duplicate@example.com" }
  let(:user_with_duplicate_email) do
    {
      email: duplicate_email,
      password: valid_password,
      password_confirmation: valid_password_confirmation
    }
  end
  
  # Factory-based user data (if using FactoryBot)
  let(:user_attributes_from_factory) { attributes_for(:user) }
end

# Auto-include in system specs
RSpec.configure do |config|
  config.include_context "signup test data", type: :system
end

