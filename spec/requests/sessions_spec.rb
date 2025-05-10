require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }
  
  describe "GET /login" do
    it "returns http success" do
      get login_path
      expect(response).to have_http_status(:success)
    end
    
    it "redirects to root if already logged in" do
      sign_in(user)
      get login_path
      expect(response).to redirect_to(root_path)
    end
  end
  
  describe "POST /login" do
    context "with valid credentials" do
      it "logs in the user" do
        post login_path, params: { email: user.email, password: "password123" }
        
        follow_redirect!
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Logged in successfully")
        expect(cookies[:remember_token]).to be_nil
      end
      
      it "remembers the user when remember me is checked" do
        post login_path, params: { 
          email: user.email, 
          password: "password123",
          remember_me: "1"
        }
        
        follow_redirect!
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Logged in successfully")
        expect(cookies[:remember_token]).to be_present
      end
    end
    
    context "with invalid credentials" do
      it "doesn't log in with wrong password" do
        post login_path, params: { email: user.email, password: "wrong_password" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Invalid email/password combination")
      end
      
      it "doesn't log in with non-existent email" do
        post login_path, params: { email: "nonexistent@example.com", password: "password123" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Invalid email/password combination")
      end
    end
  end
  
  describe "DELETE /logout" do
    it "logs out the user" do
      sign_in(user)
      remember_user(user)
      
      # Store token before logout for comparison
      token_before = cookies[:remember_token]
      expect(token_before).to be_present
      
      delete logout_path
      follow_redirect!
      expect(response).to have_http_status(:success)
      expect(response.body).to include("You have been logged out")
      
      # Cookie is either nil or blank after logout
      expect(cookies[:remember_token].to_s).to be_empty
    end
  end
end
