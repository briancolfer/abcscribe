require 'rails_helper'

RSpec.describe Observation, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      observation = build(:observation)
      expect(observation).to be_valid
    end
    
    it "is not valid without an observed_at time" do
      observation = build(:observation, observed_at: nil)
      expect(observation).not_to be_valid
      expect(observation.errors[:observed_at]).to include("can't be blank")
    end
    
    it "is not valid without an antecedent" do
      observation = build(:observation, antecedent: nil)
      expect(observation).not_to be_valid
      expect(observation.errors[:antecedent]).to include("can't be blank")
    end
    
    it "is not valid without a behavior" do
      observation = build(:observation, behavior: nil)
      expect(observation).not_to be_valid
      expect(observation.errors[:behavior]).to include("can't be blank")
    end
    
    it "is not valid without a consequence" do
      observation = build(:observation, consequence: nil)
      expect(observation).not_to be_valid
      expect(observation.errors[:consequence]).to include("can't be blank")
    end

    describe "observed_at_not_in_future validation" do
      it "is not valid with a future date" do
        observation = build(:observation, observed_at: 1.day.from_now)
        expect(observation).not_to be_valid
        expect(observation.errors[:observed_at]).to include("cannot be in the future")
      end

      it "is valid with a current date" do
        observation = build(:observation, observed_at: Time.current)
        expect(observation).to be_valid
      end

      it "is valid with a past date" do
        observation = build(:observation, observed_at: 1.day.ago)
        expect(observation).to be_valid
      end
    end
  end
  
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:subject) }
    it { should belong_to(:setting).optional }
  end
end

