require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "GET /signup" do
    it "returns http success" do
      get signup_path
      expect(response).to have_http_status(:success)
    end

    it "redirects to root if already logged in" do
      user = create(:user)
      sign_in(user)
      get signup_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /signup" do
    let(:valid_params) do
      {
        user: {
          name: "Test User",
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    context "with valid parameters" do
      it "creates a new user and logs them in" do
        expect {
          post signup_path, params: valid_params
        }.to change(User, :count).by(1)

        follow_redirect!
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Account created successfully!")
      end
    end

    context "with invalid parameters" do
      it "does not create user with invalid email" do
        params = valid_params.deep_dup
        params[:user][:email] = "invalid_email"

        expect {
          post signup_path, params: params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create user with mismatched passwords" do
        params = valid_params.deep_dup
        params[:user][:password_confirmation] = "different"

        expect {
          post signup_path, params: params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create user with short password" do
        params = valid_params.deep_dup
        params[:user][:password] = "short"
        params[:user][:password_confirmation] = "short"

        expect {
          post signup_path, params: params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it "does not create user with missing name" do
        params = valid_params.deep_dup
        params[:user][:name] = ""

        expect {
          post signup_path, params: params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
