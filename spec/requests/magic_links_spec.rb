# spec/requests/magic_links_spec.rb
require 'rails_helper'

RSpec.describe "MagicLinks", type: :request do
  let!(:user) { create(:user, email: "test@example.com") }

  describe "GET /magic_links/new" do
    it "renders the login form" do
      get new_magic_link_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sign In via Email")
      expect(response.body).to include("<form")
    end
  end

  describe "POST /magic_links" do
    context "with a registered email" do
      it "creates a token and sends an email, then redirects with notice" do
        ActionMailer::Base.deliveries.clear

        expect {
          post magic_links_path, params: { email: user.email }
        }.to change { MagicLinkToken.count }.by(1)

        # Email delivery check
        mail = ActionMailer::Base.deliveries.last
        expect(mail).to_not be_nil
        expect(mail.to).to include(user.email)
        expect(mail.subject).to match(/login link/i)
        expect(mail.body.encoded).to include("Click below to sign in")

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to match(/Check your email for a login link/)
      end
    end

    context "with an unregistered email" do
      it "does not create a token, re-renders new, and shows an alert" do
        ActionMailer::Base.deliveries.clear

        expect {
          post magic_links_path, params: { email: "nobody@nowhere.com" }
        }.not_to change { MagicLinkToken.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("No account found for that email.")
      end
    end

    context "with invalid email format" do
      it "does not create a token and re-renders new with error" do
        expect {
          post magic_links_path, params: { email: "" }
        }.not_to change { MagicLinkToken.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("No account found for that email.")
      end
    end
  end

  describe "GET /magic_links/:token (verify)" do
    let!(:token_record) { user.magic_link_tokens.create! }

    context "with a valid token" do
      it "logs in the user, destroys the token, and redirects to journal entries" do
        get verify_magic_link_path(token_record.token)
        expect(RackSessionAccess.new(self).get(:user_id)).to eq(user.id)

        # Session should be set
        #expect(session[:user_id]).to eq(user.id)
        # Token should be destroyed
        expect(MagicLinkToken.exists?(token_record.id)).to be_falsey

        expect(response).to redirect_to(journal_entries_path)
        follow_redirect!
        expect(flash[:notice]).to match(/You’re now logged in!/)
      end
    end

    context "with an expired token" do
      it "does not log in, destroys the expired token, and redirects to new with alert" do
        token_record.update!(expires_at: 1.hour.ago)

        get verify_magic_link_path(token_record.token)

        expect(session[:user_id]).to be_nil
        expect(MagicLinkToken.exists?(token_record.id)).to be_falsey

        expect(response).to redirect_to(new_magic_link_path)
        follow_redirect!
        expect(flash[:alert]).to match(/That link is invalid or has expired/)
      end
    end

    context "with an invalid token" do
      it "does not log in and redirects to new with alert" do
        get verify_magic_link_path("nonexistenttoken123")

        expect(session[:user_id]).to be_nil
        expect(response).to redirect_to(new_magic_link_path)
        follow_redirect!
        expect(flash[:alert]).to match(/That link is invalid or has expired/)
      end
    end
  end
end