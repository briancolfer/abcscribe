require 'rails_helper'

RSpec.describe "JournalEntries", type: :request do
  let(:user) { create(:user) }
  let(:journal_entry) { create(:journal_entry, user: user) }
  
  before do
    sign_in user
  end
  
  describe "GET /journal_entries" do
    it "returns http success" do
      get "/journal_entries"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /journal_entries/:id" do
    it "returns http success" do
      get "/journal_entries/#{journal_entry.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /journal_entries/new" do
    it "returns http success" do
      get "/journal_entries/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /journal_entries" do
    it "creates a journal entry and redirects" do
      post "/journal_entries", params: {
        journal_entry: {
          antecedent: "Test antecedent",
          behavior: "Test behavior", 
          consequence: "Test consequence"
        }
      }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /journal_entries/:id/edit" do
    it "returns http success" do
      get "/journal_entries/#{journal_entry.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /journal_entries/:id" do
    it "updates a journal entry and redirects" do
      patch "/journal_entries/#{journal_entry.id}", params: {
        journal_entry: { antecedent: "Updated antecedent" }
      }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "DELETE /journal_entries/:id" do
    it "deletes a journal entry and redirects" do
      delete "/journal_entries/#{journal_entry.id}"
      expect(response).to have_http_status(:redirect)
    end
  end
end
