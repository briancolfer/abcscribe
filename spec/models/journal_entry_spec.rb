require 'rails_helper'

RSpec.describe JournalEntry, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:behavior) }

  it { should validate_presence_of(:occurred_at) }
  it { should validate_presence_of(:consequence) }

  context "reinforcement_type enum" do
    it "allows only positive, negative, or neutral" do
      # Test positive value
      entry = build(:journal_entry, reinforcement_type: "positive")
      expect(entry).to be_valid
      
      # Test negative value
      entry.reinforcement_type = "negative"
      expect(entry).to be_valid
      
      # Test neutral value
      entry.reinforcement_type = "neutral"
      expect(entry).to be_valid

      # Test invalid value
      expect {
        entry.reinforcement_type = "weird"
      }.to raise_error(ArgumentError, "'weird' is not a valid reinforcement_type")
    end
  end
end