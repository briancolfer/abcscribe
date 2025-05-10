# spec/support/authentication_helpers.rb
module AuthenticationHelpers
  # Sign in a user for testing
  def sign_in(user, remember: false)
    # Set the session directly for testing
    session[:user_id] = user.id
    
    # This is for actual session creation in integration tests
    post login_path, params: { 
      email: user.email, 
      password: "password123",
      remember_me: remember ? "1" : "0"
    }
    user
  end
  
  # Signs in and returns user for contexts where the user object is needed
  def sign_in_as(user)
    session[:user_id] = user.id
    user
  end
  
  # Create and sign in a user
  def create_and_sign_in_user
    user = create(:user)
    sign_in(user)
    user
  end
  
  # Sets remember token for a user (in test environment)
  def remember_user(user)
    user.remember
    # In tests, we use plain cookies but with expiration date
    cookies[:remember_token] = {
      value: user.remember_token,
      expires: 2.weeks.from_now
    }
  end
end
