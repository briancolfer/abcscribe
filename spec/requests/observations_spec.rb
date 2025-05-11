require 'rails_helper'

RSpec.describe "Observations", type: :request do
  let(:user) { create(:user) }
  let(:subject_record) { create(:subject, user: user) }
  let(:setting) { create(:setting, user: user) }
  let(:observation) { create(:observation, user: user, subject: subject_record, setting: setting) }
  
  let(:valid_attributes) do
    {
      observed_at: Time.current,
      antecedent: "Teacher asked to complete worksheet",
      behavior: "Began task immediately",
      consequence: "Completed worksheet successfully",
      notes: "Good focus today",
      setting_id: setting.id
    }
  end

  let(:invalid_attributes) do
    {
      observed_at: nil,
      antecedent: "",
      behavior: "",
      consequence: "",
      setting_id: nil
    }
  end

  describe "GET /subjects/:subject_id/observations" do
    context "when not logged in" do
      it "redirects to login page" do
        get subject_observations_path(subject_record)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      it "renders a successful response" do
        get subject_observations_path(subject_record)
        expect(response).to be_successful
      end
    end
  end

  describe "GET /observations/:id" do
    context "when not logged in" do
      it "redirects to login page" do
        get observation_path(observation)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      it "renders a successful response" do
        get observation_path(observation)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /subjects/:subject_id/observations" do
    context "when not logged in" do
      it "redirects to login page" do
        post subject_observations_path(subject_record), params: { observation: valid_attributes }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      context "with valid parameters" do
        it "creates a new Observation" do
          expect {
            post subject_observations_path(subject_record), params: { observation: valid_attributes }
          }.to change(Observation, :count).by(1)
        end

        it "redirects to the subject page" do
          post subject_observations_path(subject_record), params: { observation: valid_attributes }
          expect(response).to redirect_to(subject_path(subject_record))
        end
      end

      context "with invalid parameters" do
        it "does not create a new Observation" do
          expect {
            post subject_observations_path(subject_record), params: { observation: invalid_attributes }
          }.to change(Observation, :count).by(0)
        end

        it "renders a response with 422 status" do
          post subject_observations_path(subject_record), params: { observation: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "PATCH /observations/:id" do
    let(:new_attributes) do
      {
        antecedent: "Updated antecedent",
        behavior: "Updated behavior",
        consequence: "Updated consequence"
      }
    end

    context "when not logged in" do
      it "redirects to login page" do
        patch observation_path(observation), params: { observation: new_attributes }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      context "with valid parameters" do
        it "updates the observation" do
          patch observation_path(observation), params: { observation: new_attributes }
          observation.reload
          expect(observation.antecedent).to eq("Updated antecedent")
          expect(observation.behavior).to eq("Updated behavior")
          expect(observation.consequence).to eq("Updated consequence")
        end

        it "redirects to the observation" do
          patch observation_path(observation), params: { observation: new_attributes }
          expect(response).to redirect_to(observation_path(observation))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status" do
          patch observation_path(observation), params: { observation: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "DELETE /observations/:id" do
    context "when not logged in" do
      it "redirects to login page" do
        delete observation_path(observation)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      it "destroys the observation" do
        observation_to_delete = observation
        expect {
          delete observation_path(observation_to_delete)
        }.to change(Observation, :count).by(-1)
      end

      it "redirects to the subject page" do
        subject_id = observation.subject_id
        delete observation_path(observation)
        expect(response).to redirect_to(subject_path(subject_id))
      end
    end
  end
end
