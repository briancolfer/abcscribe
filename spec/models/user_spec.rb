require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      user = build(:user)
      expect(user).to be_valid
    end
    
    it "is not valid without a name" do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end
    
    it "is not valid without an email" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end
    
    it "is not valid with a duplicate email" do
      create(:user, email: "test@example.com")
      user = build(:user, email: "test@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end
    
    it "is not valid with an invalid email format" do
      user = build(:user, :with_invalid_email)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("must be a valid email address")
    end
    
    it "is not valid with a short password" do
      user = build(:user, :with_short_password)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
    end
    
    it "is not valid when password and confirmation don't match" do
      user = build(:user, password: "password123", password_confirmation: "different")
      expect(user).not_to be_valid
    end
  end
  
  describe "callbacks" do
    it "converts email to lowercase before saving" do
      user = create(:user, email: "TEST@EXAMPLE.COM")
      expect(user.email).to eq("test@example.com")
    end
  end
  
  describe "authentication" do
    it "authenticates with correct password" do
      user = create(:user, password: "correct_password", password_confirmation: "correct_password")
      expect(user.authenticate("correct_password")).to eq(user)
    end
    
    it "does not authenticate with incorrect password" do
      user = create(:user, password: "correct_password", password_confirmation: "correct_password")
      expect(user.authenticate("wrong_password")).to be_falsey
    end
  end
  
  describe "remember token" do
    it "can generate a remember token" do
      user = create(:user)
      expect(User.generate_token).to be_present
    end
    
    it "can remember the user" do
      user = create(:user)
      user.remember
      expect(user.remember_token).to be_present
      expect(user.remember_created_at).to be_present
    end
    
    it "can forget the user" do
      user = create(:user)
      user.remember
      user.forget
      expect(user.remember_token).to be_nil
      expect(user.remember_created_at).to be_nil
    end
    
    it "identifies a remembered user" do
      user = create(:user)
      expect(user.remembered?).to be_falsey
      
      user.remember
      expect(user.remembered?).to be_truthy
      
      # Simulate token expired
      user.update_column(:remember_created_at, 3.weeks.ago)
      expect(user.remembered?).to be_falsey
    end
  end
end
