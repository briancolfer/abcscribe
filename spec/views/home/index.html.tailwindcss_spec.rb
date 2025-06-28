require 'rails_helper'

RSpec.describe "home/index.html.erb", type: :view do
  context "when user is not signed in" do
    before do
      allow(view).to receive(:user_signed_in?).and_return(false)
      render
    end

    it "displays the welcome message" do
      expect(rendered).to include("Welcome to ABCScribe")
    end

    it "shows sign in prompt" do
      expect(rendered).to include("Please sign in to access your account")
    end

    it "displays sign in and sign up links" do
      expect(rendered).to include("Sign In")
      expect(rendered).to include("Sign Up")
    end

    it "does not display authenticated user content" do
      expect(rendered).not_to include("Hello:")
      expect(rendered).not_to include("Edit Profile")
      expect(rendered).not_to include("Sign Out")
    end
  end

  context "when user is signed in" do
    let(:user) { build(:user, email: "test@example.com") }

    before do
      allow(view).to receive(:user_signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(user)
      render
    end

    it "displays the welcome message" do
      expect(rendered).to include("Welcome to ABCScribe")
    end

    it "shows user greeting" do
      expect(rendered).to include("Hello: #{user.email}")
    end

    it "displays authenticated user links" do
      expect(rendered).to include("Edit Profile")
      expect(rendered).to include("Sign Out")
    end

    it "does not display sign in prompt" do
      expect(rendered).not_to include("Please sign in to access your account")
    end
  end
end
