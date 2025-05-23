require 'rails_helper'

RSpec.describe "Navigation", type: :feature do
  let(:user) { create(:user, name: "Test User") }

  describe "header" do
    context "when logged in" do
      before do
        sign_in(user)
        visit root_path
      end

      it "displays the user's name" do
        within("header") do
          expect(page).to have_content(user.name)
        end
      end

      it "displays logout link" do
        within("header") do
          expect(page).to have_button("Logout")
        end
      end
    end

    context "when logged out" do
      before do
        visit root_path
      end

      it "does not display a user name" do
        within("header") do
          expect(page).not_to have_content(user.name)
        end
      end

      it "displays login and signup links" do
        within("header") do
          expect(page).to have_link("Log In")
          expect(page).to have_link("Sign Up")
        end
      end
    end
  end
end

