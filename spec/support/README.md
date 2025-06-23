# Test Support Files

This directory contains helper modules and shared contexts to DRY up tests across the application.

## Signup Helpers

### SignupHelpers Module (`signup_helpers.rb`)

Provides page object methods for user signup functionality:

#### Navigation Methods
- `visit_signup_page` - Navigates to the `/signup` page
- `expect_to_be_on_signup_page` - Verifies user is on the signup page

#### Form Interaction Methods
- `fill_in_signup_form(email:, password:, password_confirmation: nil)` - Fills all signup form fields
- `fill_in_email(email)` - Fills only the email field
- `fill_in_password(password)` - Fills only the password field
- `fill_in_password_confirmation(password_confirmation)` - Fills only the password confirmation field
- `submit_signup_form` - Clicks the "Create Account" button

#### Complete Actions
- `complete_signup(email:, password:, password_confirmation: nil)` - Visits signup page, fills form, and submits

#### Assertion Methods
- `expect_signup_success` - Expects successful signup message
- `expect_signup_error(message = nil)` - Expects error message or any error styling

### Signup Shared Context (`shared_contexts/signup_context.rb`)

Provides `let` blocks for common test data:

#### Valid Data
- `valid_email` - Valid email address
- `valid_password` - Valid password
- `valid_password_confirmation` - Valid password confirmation
- `valid_user_attributes` - Hash with all valid attributes
- `unique_email` - Generates unique email for each test

#### Invalid Data
- `invalid_email` - Invalid email format
- `blank_email` - Empty email
- `short_password` - Password too short
- `mismatched_password_confirmation` - Different confirmation password

#### Invalid Data Collections
- `user_with_invalid_email` - Attributes with invalid email
- `user_with_blank_email` - Attributes with blank email
- `user_with_short_password` - Attributes with short password
- `user_with_mismatched_password` - Attributes with mismatched confirmation

## Usage Examples

### Basic Signup Test
```ruby
it "allows user to sign up" do
  complete_signup(
    email: valid_email,
    password: valid_password
  )
  expect_signup_success
end
```

### Using Let Blocks
```ruby
it "handles invalid data" do
  complete_signup(**user_with_invalid_email)
  expect_signup_error("Email is invalid")
end
```

### Step-by-step Form Interaction
```ruby
it "fills form manually" do
  visit_signup_page
  fill_in_email(unique_email)
  fill_in_password(valid_password)
  fill_in_password_confirmation(valid_password)
  submit_signup_form
  expect_signup_success
end
```

## Auto-inclusion

Both `SignupHelpers` and the "signup test data" shared context are automatically included in all `:system` type specs. No manual inclusion required.

