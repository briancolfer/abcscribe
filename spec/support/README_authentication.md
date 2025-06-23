# Authentication Helpers for RSpec System Tests

This documentation describes the authentication support files created for comprehensive system testing.

## Files Created

### 1. `spec/support/authentication_helpers.rb`

A module containing helper methods for authentication-related system tests.

#### Page Navigation Methods
- `visit_sign_in_page` - Navigates to the sign-in page
- `visit_protected_page` - Navigates to a protected page (journal entries)

#### Form Interaction Methods
- `fill_in_sign_in_credentials(email:, password:, remember_me: false)` - Fills in sign-in form
- `submit_sign_in_form` - Clicks the sign-in button
- `complete_sign_in(email:, password:, remember_me: false)` - Complete sign-in flow
- `fill_in_email(email)` - Fills in email field
- `fill_in_password(password)` - Fills in password field
- `check_remember_me` / `uncheck_remember_me` - Toggle remember me checkbox

#### Success Validation Methods
- `expect_sign_in_success` - Verifies successful sign-in state
- `expect_sign_in_success_with_email(email)` - Verifies success with specific email
- `expect_sign_out_success` - Verifies successful sign-out state

#### Error Validation Methods
- `expect_sign_in_error(message = nil)` - Verifies sign-in error state
- `expect_invalid_credentials_error` - Verifies invalid credentials error
- `expect_to_be_on_sign_in_page` - Verifies currently on sign-in page
- `expect_redirect_to_sign_in` - Verifies redirect to sign-in page

#### Authentication State Methods
- `expect_user_to_be_signed_in` - Verifies user is signed in
- `expect_user_to_be_signed_out` - Verifies user is signed out

#### Sign Out Methods
- `sign_out_user` - Clicks sign out link
- `sign_out_programmatically` - Signs out using Warden helper

#### Programmatic Authentication (for test setup)
- `sign_in_user(user)` - Signs in user programmatically using Warden

### 2. `spec/support/shared_contexts/authentication_context.rb`

A shared context providing test data for authentication scenarios.

#### Valid Credentials
- `valid_email` - "test@example.com"
- `valid_password` - "password123"
- `valid_user_credentials` - Hash with valid email/password
- `valid_user` - FactoryBot user with valid credentials

#### Invalid Credentials
- `invalid_email` - "not-an-email"
- `invalid_password` - "wrong"
- `blank_email` / `blank_password` - Empty strings
- `nonexistent_email` - Email not in database
- Various credential combination hashes

#### FactoryBot Integration
- `user_attributes_from_factory` - Attributes from factory
- `another_user` - Different user for multi-user tests
- Users with specific emails and edge cases

#### Edge Cases
- `edge_case_email` - Email with plus sign
- `email_with_dots` - Email with dots
- `email_with_subdomain` - Email with subdomain
- `weak_password` / `strong_password` - Password variations

### 3. `spec/system/user_authentication_spec.rb`

Example system spec demonstrating usage of the helpers and shared context.

## Usage

Both the helpers module and shared context are automatically included in all system specs through RSpec configuration.

### Basic Usage

```ruby
RSpec.describe 'Some Feature', type: :system do
  it 'requires authentication' do
    visit_protected_page
    expect_redirect_to_sign_in
    
    complete_sign_in(
      email: valid_email,
      password: valid_password
    )
    expect_sign_in_success
  end
end
```

### Using Programmatic Authentication

```ruby
RSpec.describe 'Authenticated Feature', type: :system do
  before do
    sign_in_user(valid_user)
  end
  
  it 'allows access to protected functionality' do
    visit_protected_page
    expect(page).to have_content('Some Protected Content')
  end
end
```

### Testing Error Cases

```ruby
it 'shows error for invalid credentials' do
  complete_sign_in(**invalid_password_credentials)
  expect_invalid_credentials_error
end
```

## Integration with Existing Patterns

These helpers follow the same patterns as the existing `signup_helpers.rb` and `signup_context.rb` files:

- Modular design with focused responsibilities
- Automatic inclusion in system specs
- Consistent naming conventions
- FactoryBot integration
- Comprehensive test data coverage

## Dependencies

- RSpec
- Capybara (for system tests)
- FactoryBot Rails
- Warden test helpers (for programmatic authentication)
- Devise (authentication system)
