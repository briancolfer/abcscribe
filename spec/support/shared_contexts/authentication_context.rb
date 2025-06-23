RSpec.shared_context "authentication test data" do
  # Valid user credentials for testing
  let(:valid_email) { "test@example.com" }
  let(:valid_password) { "password123" }
  
  # Valid user attributes hash
  let(:valid_user_credentials) do
    {
      email: valid_email,
      password: valid_password
    }
  end
  
  # Invalid credentials for error testing
  let(:invalid_email) { "not-an-email" }
  let(:invalid_password) { "wrong" }
  let(:blank_email) { "" }
  let(:blank_password) { "" }
  let(:nonexistent_email) { "nonexistent@example.com" }
  let(:short_password) { "123" }
  
  # Invalid credential combinations
  let(:invalid_email_credentials) do
    {
      email: invalid_email,
      password: valid_password
    }
  end
  
  let(:invalid_password_credentials) do
    {
      email: valid_email,
      password: invalid_password
    }
  end
  
  let(:blank_email_credentials) do
    {
      email: blank_email,
      password: valid_password
    }
  end
  
  let(:blank_password_credentials) do
    {
      email: valid_email,
      password: blank_password
    }
  end
  
  let(:nonexistent_user_credentials) do
    {
      email: nonexistent_email,
      password: valid_password
    }
  end
  
  let(:wrong_password_credentials) do
    {
      email: valid_email,
      password: invalid_password
    }
  end
  
  # FactoryBot-based user creation
  let(:valid_user) { create(:user, email: valid_email, password: valid_password) }
  let(:another_user) { create(:user) }
  
  # User with custom attributes
  let(:user_with_custom_email) do
    create(:user, email: "custom@example.com", password: valid_password)
  end
  
  # Helper for generating unique test emails
  let(:unique_email) { "user#{SecureRandom.hex(4)}@example.com" }
  
  # User creation with unique email
  let(:user_with_unique_email) do
    create(:user, email: unique_email, password: valid_password)
  end
  
  # Factory-based user attributes (for use with build vs create)
  let(:user_attributes_from_factory) { attributes_for(:user) }
  let(:valid_user_attributes_from_factory) do
    attributes_for(:user, email: valid_email, password: valid_password)
  end
  
  # Multiple users for testing user-specific functionality
  let(:first_user) { create(:user, email: "first@example.com", password: valid_password) }
  let(:second_user) { create(:user, email: "second@example.com", password: valid_password) }
  
  # User with remember_me testing
  let(:remember_me_credentials) do
    {
      email: valid_email,
      password: valid_password,
      remember_me: true
    }
  end
  
  # Existing user scenario (for testing duplicate email errors in signup)
  let(:existing_user_email) { "existing@example.com" }
  let(:existing_user) { create(:user, email: existing_user_email, password: valid_password) }
  let(:duplicate_email_credentials) do
    {
      email: existing_user_email,
      password: valid_password
    }
  end
  
  # Common password variations for testing
  let(:weak_password) { "123" }
  let(:strong_password) { "StrongPassword123!" }
  let(:very_long_password) { "a" * 100 }
  
  # Edge case emails
  let(:edge_case_email) { "user+test@example.com" }
  let(:email_with_dots) { "user.name@example.com" }
  let(:email_with_subdomain) { "user@mail.example.com" }
  
  # Users with edge case emails
  let(:user_with_plus_email) do
    create(:user, email: edge_case_email, password: valid_password)
  end
  
  let(:user_with_dot_email) do
    create(:user, email: email_with_dots, password: valid_password)
  end
  
  let(:user_with_subdomain_email) do
    create(:user, email: email_with_subdomain, password: valid_password)
  end
end

# Auto-include in system specs
RSpec.configure do |config|
  config.include_context "authentication test data", type: :system
end
