require 'rails_helper'

RSpec.describe "Api::V1::Subjects", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:subject_record) { create(:subject, user: user) }
  let(:other_user_subject) { create(:subject, user: other_user) }
  
  let(:valid_attributes) do
    {
      name: "Test Subject",
      date_of_birth: "2020-01-01",
      notes: "Test notes for subject"
    }
  end
  
  let(:invalid_attributes) { { name: "" } }

  before do
    user.generate_api_token
    @token = user.api_token
  end

  describe "GET /api/v1/subjects" do
    context "when authenticated" do
      before do
        create_list(:subject, 3, user: user)
        create_list(:subject, 2, user: other_user)  # Should not be included
      end

      it "returns only the user's subjects" do
        get "/api/v1/subjects", headers: { 'Authorization' => "Bearer #{@token}" }
        
        expect(response).to have_http_status(:success)
        expect(json_response['data'].length).to eq(3)
        expect(json_response['data'].first['type']).to eq('subject')
      end

      it "returns subjects in case-insensitive alphabetical order" do
        # Clear existing subjects for this user to ensure a clean test environment
        Subject.where(user: user).destroy_all
        
        # Create subjects with mixed case to test case-insensitive sorting
        create(:subject, name: "alpha", user: user)
        create(:subject, name: "Beta", user: user)
        create(:subject, name: "CHARLIE", user: user)
        create(:subject, name: "delta", user: user)

        get "/api/v1/subjects", headers: auth_headers(@token)

        expect(response).to have_http_status(:success)
        names = json_response['data'].map { |s| s['attributes']['name'] }
        
        # Verify that the returned order matches case-insensitive sorting
        expect(names.map(&:downcase)).to eq(names.map(&:downcase).sort)
        
        # Additionally verify the actual order includes all our test subjects
        expect(names.map(&:downcase)).to eq(['alpha', 'beta', 'charlie', 'delta'])
      end
    end

    context "when not authenticated" do
      it "returns unauthorized" do
        get "/api/v1/subjects"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/subjects/:id" do
    context "when authenticated" do
      it "returns the requested subject" do
        get "/api/v1/subjects/#{subject_record.id}", 
            headers: { 'Authorization' => "Bearer #{@token}" }
        
        expect(response).to have_http_status(:success)
        expect(json_response['data']['id']).to eq(subject_record.id.to_s)
        expect(json_response['data']['attributes']['name']).to eq(subject_record.name)
      end

      it "includes recent observations in the response" do
        create_list(:observation, 3, subject: subject_record, user: user)
        
        get "/api/v1/subjects/#{subject_record.id}", 
            headers: { 'Authorization' => "Bearer #{@token}" }
        
        expect(json_response['included']).to be_present
        expect(json_response['included'].length).to eq(3)
      end

      it "returns not found for other user's subject" do
        get "/api/v1/subjects/#{other_user_subject.id}", 
            headers: { 'Authorization' => "Bearer #{@token}" }
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/v1/subjects" do
    context "with valid parameters" do
      it "creates a new Subject" do
        expect {
          post "/api/v1/subjects",
               params: { subject: valid_attributes },
               headers: { 'Authorization' => "Bearer #{@token}" }
        }.to change(Subject, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']['name']).to eq(valid_attributes[:name])
      end

      it "associates the subject with the current user" do
        post "/api/v1/subjects",
             params: { subject: valid_attributes },
             headers: { 'Authorization' => "Bearer #{@token}" }

        expect(Subject.last.user).to eq(user)
      end
    end

    context "with invalid parameters" do
      it "returns validation errors" do
        post "/api/v1/subjects",
             params: { subject: invalid_attributes },
             headers: { 'Authorization' => "Bearer #{@token}" }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to have_key('name')
      end

      it "does not create a subject with future date of birth" do
        post "/api/v1/subjects",
             params: { subject: valid_attributes.merge(date_of_birth: 1.day.from_now) },
             headers: { 'Authorization' => "Bearer #{@token}" }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to have_key('date_of_birth')
      end
    end
  end

  describe "PATCH/PUT /api/v1/subjects/:id" do
    context "with valid parameters" do
      let(:new_attributes) { { name: "Updated Name" } }

      it "updates the requested subject" do
        patch "/api/v1/subjects/#{subject_record.id}",
              params: { subject: new_attributes },
              headers: { 'Authorization' => "Bearer #{@token}" }

        subject_record.reload
        expect(subject_record.name).to eq("Updated Name")
        expect(response).to have_http_status(:success)
      end

      it "cannot update another user's subject" do
        patch "/api/v1/subjects/#{other_user_subject.id}",
              params: { subject: new_attributes },
              headers: { 'Authorization' => "Bearer #{@token}" }

        expect(response).to have_http_status(:not_found)
        other_user_subject.reload
        expect(other_user_subject.name).not_to eq("Updated Name")
      end
    end

    context "with invalid parameters" do
      it "returns validation errors" do
        patch "/api/v1/subjects/#{subject_record.id}",
              params: { subject: invalid_attributes },
              headers: { 'Authorization' => "Bearer #{@token}" }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to have_key('name')
      end
    end
  end

  describe "DELETE /api/v1/subjects/:id" do
    it "destroys the requested subject" do
      subject_to_delete = subject_record

      expect {
        delete "/api/v1/subjects/#{subject_to_delete.id}",
               headers: { 'Authorization' => "Bearer #{@token}" }
      }.to change(Subject, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "cannot delete another user's subject" do
      # Force creation of subject before checking count
      subject_id = other_user_subject.id
      
      expect {
        delete "/api/v1/subjects/#{subject_id}",
               headers: { 'Authorization' => "Bearer #{@token}" }
      }.not_to change(Subject, :count)

      expect(response).to have_http_status(:not_found)
    end

    it "deletes associated observations" do
      create_list(:observation, 3, subject: subject_record, user: user)
      
      expect {
        delete "/api/v1/subjects/#{subject_record.id}",
               headers: { 'Authorization' => "Bearer #{@token}" }
      }.to change(Observation, :count).by(-3)
    end
  end
end

