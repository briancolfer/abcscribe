require 'rails_helper'

RSpec.describe "Api::V1::Authentication", type: :request do
  let(:user) { create(:user) }

  describe "POST /api/v1/auth/login" do
    let(:valid_credentials) do
      {
        email: user.email,
        password: "password123"
      }
    end

    context "with valid credentials" do
      it "returns JWT token" do
        post "/api/v1/auth/login", params: valid_credentials
        
        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']['token']).to be_present
        expect(json_response['data']['attributes']['email']).to eq(user.email)
      end

      it "returns token that can be used for authentication" do
        post "/api/v1/auth/login", params: valid_credentials
        token = json_response['data']['attributes']['token']
        
        get "/api/v1/subjects", headers: auth_headers(token)
        expect(response).to have_http_status(:success)
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized for wrong password" do
        post "/api/v1/auth/login", params: {
          email: user.email,
          password: "wrong_password"
        }
        
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['errors'].first['detail']).to eq("Invalid email or password")
      end

      it "returns unauthorized for non-existent email" do
        post "/api/v1/auth/login", params: {
          email: "nonexistent@example.com",
          password: "password123"
        }
        
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['errors'].first['detail']).to eq("Invalid email or password")
      end
    end
  end

  describe "DELETE /api/v1/auth/logout" do
    context "when authenticated" do
      before do
        user.generate_api_token
        @token = user.api_token
      end

      it "invalidates the token" do
        delete "/api/v1/auth/logout", headers: auth_headers(@token)
        
        expect(response).to have_http_status(:no_content)
        user.reload
        expect(user.api_token).to be_nil
      end

      it "prevents further use of the invalidated token" do
        delete "/api/v1/auth/logout", headers: auth_headers(@token)
        get "/api/v1/subjects", headers: auth_headers(@token)
        
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when not authenticated" do
      it "returns unauthorized without token" do
        delete "/api/v1/auth/logout"
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns unauthorized with invalid token" do
        delete "/api/v1/auth/logout", headers: auth_headers("invalid_token")
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

