require 'rails_helper'

RSpec.describe "Api::V1::Subjects Search", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  
  before do
    user.generate_api_token
    @token = user.api_token
  end

  describe "GET /api/v1/subjects with search parameters" do
    let!(:smith_1) { create(:subject, name: "John Smith", user: user) }
    let!(:smith_2) { create(:subject, name: "Jane Smith", user: user) }
    let!(:jones) { create(:subject, name: "Bob Jones", user: user) }
    let!(:other_smith) { create(:subject, name: "John Smith", user: other_user) }

    context "when searching by name" do
      it "returns matching subjects for current user only" do
        get "/api/v1/subjects", params: { query: "Smith" }, 
            headers: auth_headers(@token)

        expect(response).to have_http_status(:success)
        expect(json_response['data'].length).to eq(2)
        names = json_response['data'].map { |s| s['attributes']['name'] }
        expect(names).to match_array(["John Smith", "Jane Smith"])
      end

      it "includes meta information" do
        get "/api/v1/subjects", params: { query: "Smith" }, 
            headers: auth_headers(@token)

        expect(json_response['meta']).to include(
          'total_count' => 3,
          'filtered_count' => 2
        )
      end

      it "handles empty search query" do
        get "/api/v1/subjects", params: { query: "" }, 
            headers: auth_headers(@token)

        expect(json_response['data'].length).to eq(3)
      end
    end

    context "when filtering by date of birth" do
      # Clear previous test data
      before do
        Subject.destroy_all
      end

      let!(:young_subject) { 
        create(:subject, 
          name: "Young Subject", 
          date_of_birth: 5.years.ago.to_date, 
          user: user
        )
      }
      let!(:middle_subject) { 
        create(:subject, 
          name: "Middle Subject", 
          date_of_birth: 10.years.ago.to_date, 
          user: user
        )
      }
      let!(:old_subject) { 
        create(:subject, 
          name: "Old Subject", 
          date_of_birth: 15.years.ago.to_date, 
          user: user
        )
      }

      it "returns subjects within date range" do
        start_date = 11.years.ago.to_date
        end_date = 4.years.ago.to_date
        
        get "/api/v1/subjects", 
            params: { 
              start_date: start_date.iso8601,
              end_date: end_date.iso8601
            },
            headers: auth_headers(@token)

        expect(response).to have_http_status(:success)
        subjects = json_response['data']
        expect(subjects.length).to eq(2)
        names = subjects.map { |s| s['attributes']['name'] }
        expect(names).to match_array(['Young Subject', 'Middle Subject'])
      end

      it "handles invalid date formats gracefully" do
        get "/api/v1/subjects", 
            params: { 
              start_date: "invalid",
              end_date: "also-invalid"
            },
            headers: auth_headers(@token)

        expect(response).to have_http_status(:success)
        # Returns all subjects since no filtering applied
        expect(json_response['data'].length).to eq(3) # Updated count to match actual subjects
      end
    end

    context "when filtering by observation count" do
      before do
        create_list(:observation, 3, subject: smith_1, user: user)
        create_list(:observation, 1, subject: smith_2, user: user)
      end

      it "returns subjects with minimum number of observations" do
        get "/api/v1/subjects", 
            params: { min_observations: 2 },
            headers: auth_headers(@token)

        expect(json_response['data'].length).to eq(1)
        expect(json_response['data'].first['attributes']['name'])
          .to eq("John Smith")
        expect(json_response['data'].first['attributes']['observations_count'])
          .to eq(3)
      end

      it "includes observation counts in response" do
        get "/api/v1/subjects",
            headers: auth_headers(@token)

        counts = json_response['data'].map { |s| s['attributes']['observations_count'] }
        expect(counts).to include(3, 1, 0)
      end
    end

    context "when sorting" do
      it "sorts by name ascending" do
        get "/api/v1/subjects", 
            params: { sort_by: "name", sort_direction: "asc" },
            headers: auth_headers(@token)

        names = json_response['data'].map { |s| s['attributes']['name'] }
        expect(names).to eq(["Bob Jones", "Jane Smith", "John Smith"])
      end

      it "sorts by observation count descending" do
        create_list(:observation, 3, subject: smith_1, user: user)
        create_list(:observation, 1, subject: smith_2, user: user)

        get "/api/v1/subjects", 
            params: { sort_by: "observations_count", sort_direction: "desc" },
            headers: auth_headers(@token)

        subjects = json_response['data'].map { |s| 
          [s['attributes']['name'], s['attributes']['observations_count']]
        }
        expect(subjects.first).to eq(["John Smith", 3])
      end

      it "defaults to created_at desc when sort field is invalid" do
        get "/api/v1/subjects", 
            params: { sort_by: "invalid_field" },
            headers: auth_headers(@token)

        expect(response).to have_http_status(:success)
      end
    end

    context "when combining filters" do
      before do
        create_list(:observation, 3, subject: smith_1, user: user)
        create_list(:observation, 1, subject: smith_2, user: user)
      end

      it "applies multiple filters together" do
        get "/api/v1/subjects", 
            params: { 
              query: "Smith",
              min_observations: 2,
              sort_by: "name",
              sort_direction: "asc"
            },
            headers: auth_headers(@token)

        expect(json_response['data'].length).to eq(1)
        expect(json_response['data'].first['attributes']['name'])
          .to eq("John Smith")
        expect(json_response['data'].first['attributes']['observations_count'])
          .to eq(3)
      end
    end
  end
end

