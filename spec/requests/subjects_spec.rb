require 'rails_helper'

RSpec.describe "Subjects", type: :request do
  let(:user) { create(:user) }
  let(:subject_record) { create(:subject, user: user) }
  let(:valid_attributes) { attributes_for(:subject) }
  let(:invalid_attributes) { { name: "" } }

  describe "GET /subjects" do
    context "when not logged in" do
      it "redirects to login page" do
        get subjects_path
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      it "renders a successful response" do
        get subjects_path
        expect(response).to be_successful
      end
    end
  end

  describe "GET /subjects/:id" do
    context "when not logged in" do
      it "redirects to login page" do
        get subject_path(subject_record)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      it "renders a successful response" do
        get subject_path(subject_record)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /subjects" do
    context "when not logged in" do
      it "redirects to login page" do
        post subjects_path, params: { subject: valid_attributes }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      context "with valid parameters" do
        it "creates a new Subject" do
          expect {
            post subjects_path, params: { subject: valid_attributes }
          }.to change(Subject, :count).by(1)
        end

        it "redirects to the created subject" do
          post subjects_path, params: { subject: valid_attributes }
          expect(response).to redirect_to(subject_path(Subject.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new Subject" do
          expect {
            post subjects_path, params: { subject: invalid_attributes }
          }.to change(Subject, :count).by(0)
        end

        it "renders a response with 422 status" do
          post subjects_path, params: { subject: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
  
  describe "PATCH /subjects/:id" do
    let(:new_attributes) { { name: "Updated Name" } }
    
    context "when not logged in" do
      it "redirects to login page" do
        patch subject_path(subject_record), params: { subject: valid_attributes }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      context "with valid parameters" do
        it "updates the subject" do
          patch subject_path(subject_record), params: { subject: new_attributes }
          subject_record.reload
          expect(subject_record.name).to eq("Updated Name")
        end

        it "redirects to the subject" do
          patch subject_path(subject_record), params: { subject: new_attributes }
          expect(response).to redirect_to(subject_path(subject_record))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status" do
          patch subject_path(subject_record), params: { subject: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "DELETE /subjects/:id" do
    context "when not logged in" do
      it "redirects to login page" do
        delete subject_path(subject_record)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before { sign_in(user) }

      it "destroys the subject" do
        subject_to_delete = subject_record
        expect {
          delete subject_path(subject_to_delete)
        }.to change(Subject, :count).by(-1)
      end

      it "redirects to the subjects list" do
        delete subject_path(subject_record)
        expect(response).to redirect_to(subjects_path)
      end
    end
  end
end
