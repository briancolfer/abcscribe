# Devise Rememberable and Timeoutable Testing

This directory contains comprehensive system specs for testing Devise's rememberable and timeoutable functionality.

## Files

### `rememberable_and_timeout_spec.rb`
This is the main spec file that tests Devise's rememberable functionality. It includes:

**Rememberable Tests (Active):**
- ✅ Cookie setting when "Remember me" is checked
- ✅ Session persistence across browser restarts
- ✅ Access to protected pages without re-authentication
- ✅ Remember token expiry behavior
- ✅ Sign-out clearing remember tokens

**Timeoutable Tests (Pending):**
- ⏸️ Session timeout after idle period
- ⏸️ Activity resetting timeout period
- ⏸️ Integration with rememberable functionality

### `examples/timeoutable_configuration_example_spec.rb`
This is an example spec showing how to test timeoutable functionality when it's enabled.

## Current Status

### Rememberable (✅ Working)
The rememberable functionality is already enabled in this application:
- User model includes `:rememberable` module
- Login form includes "Remember me" checkbox
- Database has `remember_created_at` column
- All rememberable tests pass

### Timeoutable (⏸️ Available but not enabled)
The timeoutable functionality is available but not currently enabled. To enable it:

1. **Modify User model** (`app/models/user.rb`):
   ```ruby
   devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable, :timeoutable
   ```

2. **Configure timeout** in `config/initializers/devise.rb`:
   ```ruby
   config.timeout_in = 5.minutes  # or your preferred timeout
   ```

3. **Enable the tests** by removing the `skip` parameter from the test groups in `rememberable_and_timeout_spec.rb`

## Running the Tests

### Run all rememberable tests:
```bash
bundle exec rspec spec/system/rememberable_and_timeout_spec.rb --format documentation
```

### Run specific test:
```bash
bundle exec rspec spec/system/rememberable_and_timeout_spec.rb:16 --format documentation
```

### View test structure:
```bash
bundle exec rspec spec/system/rememberable_and_timeout_spec.rb --dry-run --format documentation
```

## What the Tests Cover

### Rememberable Functionality
1. **Cookie Management**
   - Verifies remember token cookies are set/cleared correctly
   - Tests cookie persistence across sessions

2. **Session Persistence**
   - Tests login persistence when browser is closed/reopened
   - Verifies access to protected pages without re-authentication

3. **Database Integration**
   - Checks `remember_created_at` timestamp management
   - Tests remember token cleanup on sign-out

4. **Security**
   - Ensures remember tokens are cleared on explicit sign-out
   - Verifies tokens don't persist when "Remember me" is unchecked

### Timeoutable Functionality (When Enabled)
1. **Session Timeout**
   - Tests automatic logout after idle period
   - Verifies timeout messages are displayed

2. **Activity Tracking**
   - Tests that user activity resets timeout period
   - Verifies session maintenance with regular activity

3. **Integration with Rememberable**
   - Tests that remember tokens override session timeout
   - Verifies proper interaction between both features

## Technical Implementation Details

### Cookie Handling
The specs use a custom helper method `get_remember_token_cookie` that safely handles Selenium WebDriver cookie retrieval and gracefully handles cases where cookies don't exist.

### Time Travel
The specs include a `travel_to` helper method that works with:
- Rails 6+ built-in time travel (`Time.travel_to`)
- Timecop gem (if available)
- Graceful fallback for older versions

### Browser Session Simulation
The tests simulate browser restarts by clearing session cookies while preserving persistent cookies, accurately mimicking real-world browser behavior.

## Configuration Options

### Devise Rememberable Configuration
In `config/initializers/devise.rb`:

```ruby
# The time the user will be remembered without asking for credentials again
config.remember_for = 2.weeks

# Invalidates all remember me tokens when the user signs out
config.expire_all_remember_me_on_sign_out = true

# If true, extends the user's remember period when remembered via cookie
config.extend_remember_period = false

# Options to be passed to the created cookie
config.rememberable_options = {}
```

### Devise Timeoutable Configuration
In `config/initializers/devise.rb`:

```ruby
# The time you want to timeout the user session without activity
config.timeout_in = 30.minutes
```

## Dependencies

### Required Gems (Already in Gemfile)
- `rspec-rails` - Testing framework
- `capybara` - System testing
- `selenium-webdriver` - Browser automation
- `factory_bot_rails` - Test data generation

### Optional Gems for Enhanced Testing
- `timecop` - Time manipulation in tests (for more precise timeout testing)

## Best Practices

1. **Always test both positive and negative cases**
   - Test when remember me is checked AND unchecked
   - Test timeout scenarios AND active session scenarios

2. **Use realistic timeouts in tests**
   - Don't use extremely short timeouts that might cause flaky tests
   - Consider CI environment timing when setting test timeouts

3. **Test browser behavior accurately**
   - Simulate actual browser close/reopen scenarios
   - Test cookie persistence correctly

4. **Verify security implications**
   - Ensure tokens are cleared when expected
   - Test that unauthorized access is properly prevented

## Troubleshooting

### Common Issues

1. **Flaky timeout tests**
   - Use consistent time travel methods
   - Allow sufficient buffer time for operations
   - Consider CI environment timing differences

2. **Cookie handling errors**
   - Use the provided `get_remember_token_cookie` helper
   - Handle cases where cookies don't exist gracefully

3. **Session simulation issues**
   - Ensure proper cleanup between tests with `Capybara.reset_sessions!`
   - Clear specific cookies rather than all cookies when simulating scenarios

### Debug Helpers

Add these to your tests for debugging:

```ruby
# View all cookies
puts page.driver.browser.manage.all_cookies.inspect

# Check current session state
puts page.evaluate_script('document.cookie')

# View current user state
puts page.evaluate_script('window.location.href')
```

## Security Considerations

These tests help ensure:
- Remember tokens are securely generated and managed
- Session timeouts work as expected to prevent unauthorized access
- Proper cleanup of authentication tokens
- Correct interaction between different authentication mechanisms

Remember that these features have security implications and should be configured according to your application's security requirements.
