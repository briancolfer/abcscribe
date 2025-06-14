# spec/requests/api/v1/journal_entries_spec.rb
require 'rails_helper'

RSpec.describe "API::V1::JournalEntries", type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) do
    {
      "Authorization" => "Bearer #{token}",
      "Content-Type"  => "application/json",
      "Accept"        => "application/json"
    }
  end

  describe "GET /api/v1/journal_entries" do
    let!(:entries) { create_list(:journal_entry, 3, user: user) }
    let!(:other_user_entry) { create(:journal_entry) }

    context "when unauthenticated" do
      it "returns 401 Unauthorized" do
        get "/api/v1/journal_entries"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated" do
      it "returns a JSON list of the user's entries" do
        get "/api/v1/journal_entries", headers: headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to be_an(Array)
        expect(body.size).to eq(entries.count)

        returned_ids = body.map { |e| e["id"] }
        expect(returned_ids).to match_array(entries.map(&:id))
        # Verify fields for one entry
        sample = body.first
        expect(sample.keys).to include("id", "behavior", "antecedent", "consequence", "occurred_at", "reinforcement_type")
      end
    end
  end

  describe "POST /api/v1/journal_entries" do
    let(:valid_params) do
      {
        journal_entry: {
          occurred_at:       Time.zone.now.iso8601,
          antecedent:        "Test antecedent",
          behavior:          "Test behavior",
          consequence:       "Test consequence",
          reinforcement_type: "positive"
        }
      }.to_json
    end

    let(:invalid_params) do
      {
        journal_entry: {
          occurred_at: nil,
          behavior:    "",
          consequence: ""
        }
      }.to_json
    end

    context "when unauthenticated" do
      it "returns 401 Unauthorized" do
        post "/api/v1/journal_entries", params: valid_params, headers: { "Content-Type" => "application/json" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated" do
      it "creates a new entry with valid params" do
        expect {
          post "/api/v1/journal_entries", params: valid_params, headers: headers
        }.to change { user.journal_entries.count }.by(1)

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["behavior"]).to eq("Test behavior")
        expect(body["consequence"]).to eq("Test consequence")
        expect(body["reinforcement_type"]).to eq("positive")
      end

      it "returns errors with invalid params" do
        post "/api/v1/journal_entries", params: invalid_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to include("Behavior can't be blank", "Consequence can't be blank", "Occurred at can't be blank")
      end
    end
  end

  describe "PATCH /api/v1/journal_entries/:id" do
    let!(:entry) { create(:journal_entry, user: user, behavior: "Old behavior") }
    let(:update_params) do
      {
        journal_entry: {
          behavior: "Updated behavior",
          consequence: "Updated consequence"
        }
      }.to_json
    end

    context "when unauthenticated" do
      it "returns 401 Unauthorized" do
        patch "/api/v1/journal_entries/#{entry.id}", params: update_params, headers: { "Content-Type" => "application/json" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated" do
      it "updates the entry with valid params" do
        patch "/api/v1/journal_entries/#{entry.id}", params: update_params, headers: headers
        expect(response).to have_http_status(:ok)

        body = JSON.parse(response.body)
        expect(body["behavior"]).to eq("Updated behavior")
        expect(body["consequence"]).to eq("Updated consequence")
        expect(entry.reload.behavior).to eq("Updated behavior")
      end

      it "returns 404 Not Found for other users' entries" do
        other_entry = create(:journal_entry)
        patch "/api/v1/journal_entries/#{other_entry.id}", params: update_params, headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it "returns errors with invalid params" do
        invalid_update = { journal_entry: { behavior: "", consequence: "" } }.to_json
        patch "/api/v1/journal_entries/#{entry.id}", params: invalid_update, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to include("Behavior can't be blank", "Consequence can't be blank")
      end
    end
  end

  describe "DELETE /api/v1/journal_entries/:id" do
    let!(:entry) { create(:journal_entry, user: user) }

    context "when unauthenticated" do
      it "returns 401 Unauthorized" do
        delete "/api/v1/journal_entries/#{entry.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated" do
      it "deletes the entry" do
        expect {
          delete "/api/v1/journal_entries/#{entry.id}", headers: headers
        }.to change { user.journal_entries.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end

      it "returns 404 Not Found for other users' entries" do
        other_entry = create(:journal_entry)
        delete "/api/v1/journal_entries/#{other_entry.id}", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end