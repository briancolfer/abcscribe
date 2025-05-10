require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    context "when logged in" do
      it "shows user-specific content" do
        user = create(:user)
        sign_in(user)
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Logout")
      end
    end

    context "when not logged in" do
      it "shows signup/login options" do
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Sign Up")
        expect(response.body).to include("Log In")
      end
    end
  end
end

