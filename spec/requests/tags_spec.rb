require 'rails_helper'

RSpec.describe "Tags", type: :request do
  let(:user) { create(:user) }
  
  before do
    sign_in user
  end
  
  describe "GET /tags" do
    it "returns http success" do
      get "/tags", headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /tags" do
    it "creates a tag and returns JSON" do
      post "/tags", params: { name: "test-tag" }, headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:success)
    end
  end
end
