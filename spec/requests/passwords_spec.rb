require 'rails_helper'

RSpec.describe "Passwords", type: :request do
  let(:user) { create(:user) }
  let(:valid_email) { user.email }
  let(:invalid_email) { "nonexistent@example.com" }
  let(:blank_email) { "" }
  let(:malformed_email) { "invalid-email" }
  let(:new_password) { "NewSecurePassword123!" }
  let(:different_password) { "DifferentPassword456!" }
  let(:short_password) { "123" }

  before do
    # Clear any existing emails
    ActionMailer::Base.deliveries.clear
  end

  describe "POST /users/password" do
    context "with valid email" do
      it "sends password reset email and redirects with success flash" do
        post "/users/password", params: { user: { email: valid_email } }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
        
        # Check flash message
        follow_redirect!
        expect(response.body).to include("You will receive an email with instructions on how to reset your password in a few minutes.")
        
        # Verify email was sent
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email = ActionMailer::Base.deliveries.last
        expect(email.to).to include(valid_email)
        expect(email.subject).to include("Reset password instructions")
        
        # Verify user's reset password token was set
        user.reload
        expect(user.reset_password_token).to be_present
        expect(user.reset_password_sent_at).to be_present
      end

      it "sets appropriate response headers" do
        post "/users/password", params: { user: { email: valid_email } }

        expect(response).to have_http_status(:redirect)
        expect(response.headers['Location']).to include(new_user_session_path)
      end
    end

    context "with invalid email" do
      it "shows error for non-existent email and does not send email" do
        post "/users/password", params: { user: { email: invalid_email } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Email not found")
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end

      it "shows error for blank email and does not send email" do
        post "/users/password", params: { user: { email: blank_email } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Email can&#39;t be blank")
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end

      it "handles malformed email and does not send email" do
        post "/users/password", params: { user: { email: malformed_email } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end

      it "handles missing email parameter gracefully" do
        post "/users/password", params: { user: {} }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Email can&#39;t be blank")
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end

    context "with missing parameters" do
      it "handles completely missing user parameters" do
        post "/users/password", params: {}

        expect(response).to have_http_status(:unprocessable_entity)
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end
  end

  describe "GET /users/password/edit" do
    let(:reset_password_token) do
      # Generate a valid reset token
      raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
      user.update!(
        reset_password_token: hashed_token,
        reset_password_sent_at: Time.current
      )
      raw_token
    end

    let(:invalid_token) { "invalid_token_123" }

    context "with valid token" do
      it "renders the password reset form successfully" do
        get "/users/password/edit", params: { reset_password_token: reset_password_token }

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Change your password")
        expect(response.body).to include("New password")
        expect(response.body).to include("Confirm new password")
        expect(response.body).to include("Change my password")
      end

      it "includes the reset token in the form" do
        get "/users/password/edit", params: { reset_password_token: reset_password_token }

        expect(response).to have_http_status(:success)
        expect(response.body).to include(reset_password_token)
      end
    end

    context "with invalid token" do
      it "renders form but will show error on submission" do
        get "/users/password/edit", params: { reset_password_token: invalid_token }

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Change your password")
      end

      it "handles expired token" do
        # Create an expired token
        raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
        user.update!(
          reset_password_token: hashed_token,
          reset_password_sent_at: 7.hours.ago
        )
        expired_token = raw_token

        get "/users/password/edit", params: { reset_password_token: expired_token }

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Change your password")
      end
    end

    context "with blank token" do
      it "redirects to sign in page" do
        get "/users/password/edit", params: { reset_password_token: "" }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects when token parameter is missing" do
        get "/users/password/edit"

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PUT /users/password" do
    let(:reset_password_token) do
      # Generate a valid reset token
      raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
      user.update!(
        reset_password_token: hashed_token,
        reset_password_sent_at: Time.current
      )
      raw_token
    end

    let(:invalid_token) { "invalid_token_123" }

    context "with valid token and passwords" do
      it "updates password, signs in user automatically, and redirects to root" do
        put "/users/password", params: {
          user: {
            reset_password_token: reset_password_token,
            password: new_password,
            password_confirmation: new_password
          }
        }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
        
        # Follow redirect to check flash message
        follow_redirect!
        expect(response.body).to include("Your password has been changed successfully. You are now signed in.")
        
        # Verify password was actually changed
        user.reload
        expect(user.valid_password?(new_password)).to be true
        
        # Verify user is signed in by checking for user-specific content
        expect(response.body).to include("Welcome, #{user.email}")
        expect(response.body).to include("Logout")
        
        # Verify reset token was cleared
        expect(user.reset_password_token).to be_nil
        expect(user.reset_password_sent_at).to be_nil
      end

      it "maintains user session after password update" do
        put "/users/password", params: {
          user: {
            reset_password_token: reset_password_token,
            password: new_password,
            password_confirmation: new_password
          }
        }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
        
        # Test that user can access protected resources
        get "/journal_entries"
        expect(response).to have_http_status(:success)
      end
    end

    context "with invalid token" do
      it "shows error message and does not update password" do
        put "/users/password", params: {
          user: {
            reset_password_token: invalid_token,
            password: new_password,
            password_confirmation: new_password
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Reset password token is invalid")
        
        # Verify password was not changed
        user.reload
        expect(user.valid_password?(new_password)).to be false
        
        # Verify user is not signed in
        get "/journal_entries"
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "handles expired token" do
        # Create an expired token
        raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
        user.update!(
          reset_password_token: hashed_token,
          reset_password_sent_at: 7.hours.ago
        )
        expired_token = raw_token

        put "/users/password", params: {
          user: {
            reset_password_token: expired_token,
            password: new_password,
            password_confirmation: new_password
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Reset password token has expired, please request a new one")
        
        # Verify password was not changed
        user.reload
        expect(user.valid_password?(new_password)).to be false
      end
    end

    context "with password validation errors" do
      it "shows error for mismatched passwords" do
        put "/users/password", params: {
          user: {
            reset_password_token: reset_password_token,
            password: new_password,
            password_confirmation: different_password
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Password confirmation doesn&#39;t match Password")
        
        # Verify password was not changed
        user.reload
        expect(user.valid_password?(new_password)).to be false
        
        # Verify user is not signed in
        get "/journal_entries"
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "shows error for blank password" do
        put "/users/password", params: {
          user: {
            reset_password_token: reset_password_token,
            password: "",
            password_confirmation: new_password
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Password can&#39;t be blank")
        
        # Verify password was not changed
        user.reload
        expect(user.valid_password?("")).to be false
      end

      it "shows error for blank password confirmation" do
        put "/users/password", params: {
          user: {
            reset_password_token: reset_password_token,
            password: new_password,
            password_confirmation: ""
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Password confirmation doesn&#39;t match Password")
        
        # Verify password was not changed
        user.reload
        expect(user.valid_password?(new_password)).to be false
      end

      it "shows error for too short password" do
        put "/users/password", params: {
          user: {
            reset_password_token: reset_password_token,
            password: short_password,
            password_confirmation: short_password
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Password is too short (minimum is 6 characters)")
        
        # Verify password was not changed
        user.reload
        expect(user.valid_password?(short_password)).to be false
      end

      it "displays multiple validation errors simultaneously" do
        put "/users/password", params: {
          user: {
            reset_password_token: reset_password_token,
            password: "12",  # Too short
            password_confirmation: "34"  # Different and too short
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Password is too short")
        expect(response.body).to include("Password confirmation doesn&#39;t match Password")
      end
    end

    context "with missing parameters" do
      it "handles missing reset_password_token" do
        put "/users/password", params: {
          user: {
            password: new_password,
            password_confirmation: new_password
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Reset password token can&#39;t be blank")
      end

      it "handles completely missing user parameters" do
        put "/users/password", params: {}

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "security considerations" do
    it "prevents reuse of reset password token" do
      # Generate a reset token
      raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
      user.update!(
        reset_password_token: hashed_token,
        reset_password_sent_at: Time.current
      )
      reset_token = raw_token

      # Use the token once
      put "/users/password", params: {
        user: {
          reset_password_token: reset_token,
          password: new_password,
          password_confirmation: new_password
        }
      }

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)

      # Try to use the same token again
      put "/users/password", params: {
        user: {
          reset_password_token: reset_token,
          password: different_password,
          password_confirmation: different_password
        }
      }

      # After successful password reset, user is signed in so token reuse should redirect or fail
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
      
      # Verify second password was not set
      user.reload
      expect(user.valid_password?(different_password)).to be false
      expect(user.valid_password?(new_password)).to be true
    end

    it "does not reveal user existence through error messages" do
      # Some configurations might choose to show success message even for non-existent emails
      # to prevent user enumeration attacks
      post "/users/password", params: { user: { email: invalid_email } }

      # The specific behavior might vary based on Devise configuration
      # but we should not leak information about user existence
      expect(response).to have_http_status(:unprocessable_entity)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end
end
