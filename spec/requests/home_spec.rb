require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /" do
    context "when user is not signed in" do
      it "returns http success" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "displays welcome message" do
        get root_path
        expect(response.body).to include("Welcome to ABCScribe")
      end

      it "shows sign in and sign up links" do
        get root_path
        expect(response.body).to include("Sign In")
        expect(response.body).to include("Sign Up")
        expect(response.body).to include("Please sign in to access your account")
      end

      it "does not show user-specific content" do
        get root_path
        expect(response.body).not_to include("Hello:")
        expect(response.body).not_to include("Edit Profile")
        expect(response.body).not_to include("Sign Out")
      end
    end

    context "when user is signed in" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "returns http success" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "displays welcome message" do
        get root_path
        expect(response.body).to include("Welcome to ABCScribe")
      end

      it "shows user-specific greeting" do
        get root_path
        expect(response.body).to include("Hello: #{user.email}")
      end

      it "shows authenticated user links" do
        get root_path
        expect(response.body).to include("Edit Profile")
        expect(response.body).to include("Sign Out")
      end

      it "does not show sign in/up links" do
        get root_path
        expect(response.body).not_to include("Please sign in to access your account")
      end
    end
  end

  describe "GET /home/index" do
    it "returns http success" do
      get "/home/index"
      expect(response).to have_http_status(:success)
    end

    it "renders the same content as root path" do
      get root_path
      root_response = response.body
      
      get "/home/index"
      expect(response.body).to eq(root_response)
    end
  end
end
