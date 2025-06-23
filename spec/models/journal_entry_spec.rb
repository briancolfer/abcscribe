require 'rails_helper'

RSpec.describe JournalEntry, type: :model do
  let(:user) { create(:user) }
  let(:valid_attributes) do
    {
      antecedent: "Manager assigned new project with tight deadline",
      behavior: "Organized tasks into priority list and set 25-minute work blocks",
      consequence: "Completed first milestone ahead of schedule",
      user: user
    }
  end

  describe 'validations' do
    subject { build(:journal_entry, user: user) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    describe 'antecedent validation' do
      it 'requires antecedent to be present' do
        subject.antecedent = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:antecedent]).to include("can't be blank")
      end

      it 'requires antecedent to be at least 10 characters' do
        subject.antecedent = "Too short"
        expect(subject).not_to be_valid
        expect(subject.errors[:antecedent]).to include("is too short (minimum is 10 characters)")
      end

      it 'allows antecedent up to 1000 characters' do
        subject.antecedent = "a" * 1000
        expect(subject).to be_valid
      end

      it 'rejects antecedent over 1000 characters' do
        subject.antecedent = "a" * 1001
        expect(subject).not_to be_valid
        expect(subject.errors[:antecedent]).to include("is too long (maximum is 1000 characters)")
      end

      it 'accepts content with whitespace that meets minimum length' do
        subject.antecedent = "   This content is long enough with whitespace   "
        expect(subject).to be_valid
      end
    end

    describe 'behavior validation' do
      it 'requires behavior to be present' do
        subject.behavior = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:behavior]).to include("can't be blank")
      end

      it 'requires behavior to be at least 10 characters' do
        subject.behavior = "Short"
        expect(subject).not_to be_valid
        expect(subject.errors[:behavior]).to include("is too short (minimum is 10 characters)")
      end

      it 'allows behavior up to 1000 characters' do
        subject.behavior = "b" * 1000
        expect(subject).to be_valid
      end

      it 'rejects behavior over 1000 characters' do
        subject.behavior = "b" * 1001
        expect(subject).not_to be_valid
        expect(subject.errors[:behavior]).to include("is too long (maximum is 1000 characters)")
      end
    end

    describe 'consequence validation' do
      it 'requires consequence to be present' do
        subject.consequence = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:consequence]).to include("can't be blank")
      end

      it 'requires consequence to be at least 10 characters' do
        subject.consequence = "Brief"
        expect(subject).not_to be_valid
        expect(subject.errors[:consequence]).to include("is too short (minimum is 10 characters)")
      end

      it 'allows consequence up to 1000 characters' do
        subject.consequence = "c" * 1000
        expect(subject).to be_valid
      end

      it 'rejects consequence over 1000 characters' do
        subject.consequence = "c" * 1001
        expect(subject).not_to be_valid
        expect(subject.errors[:consequence]).to include("is too long (maximum is 1000 characters)")
      end
    end
  end

  describe 'associations' do
    subject { build(:journal_entry, user: user) }

    it 'belongs to a user' do
      expect(subject.user).to eq(user)
    end

    it 'requires a user' do
      subject.user = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:user]).to include("must exist")
    end

    it 'has many tags through journal_entry_tags' do
      expect(subject).to respond_to(:tags)
      expect(subject).to respond_to(:journal_entry_tags)
    end

    it 'can be associated with multiple tags' do
      entry = create(:journal_entry, user: user)
      tag1 = create(:tag, user: user, name: "productivity")
      tag2 = create(:tag, user: user, name: "stress")
      
      entry.tags << [tag1, tag2]
      entry.reload
      
      expect(entry.tags.count).to eq(2)
      expect(entry.tags).to include(tag1, tag2)
    end

    it 'destroys associated journal_entry_tags when deleted' do
      entry = create(:journal_entry, user: user)
      tag = create(:tag, user: user)
      entry.tags << tag
      
      expect { entry.destroy }.to change(JournalEntryTag, :count).by(-1)
    end
  end

  describe 'virtual attributes for form handling' do
    subject { build(:journal_entry, user: user) }

    it 'has tag_ids virtual attribute' do
      expect(subject).to respond_to(:tag_ids)
      expect(subject).to respond_to(:tag_ids=)
    end

    it 'has new_tags virtual attribute' do
      expect(subject).to respond_to(:new_tags)
      expect(subject).to respond_to(:new_tags=)
    end

    it 'returns empty array for tag_ids by default' do
      expect(subject.tag_ids).to eq([])
    end

    it 'returns empty array for new_tags by default' do
      expect(subject.new_tags).to eq([])
    end

    it 'can store tag_ids' do
      subject.tag_ids = ["1", "2", "3"]
      expect(subject.tag_ids).to eq(["1", "2", "3"])
    end

    it 'can store new_tags' do
      subject.new_tags = ["new-tag-1", "new-tag-2"]
      expect(subject.new_tags).to eq(["new-tag-1", "new-tag-2"])
    end
  end

  describe 'factory' do
    it 'creates a valid journal entry with factory' do
      entry = build(:journal_entry)
      expect(entry).to be_valid
    end

    it 'creates journal entry with all required fields' do
      entry = create(:journal_entry)
      expect(entry.antecedent).to be_present
      expect(entry.behavior).to be_present
      expect(entry.consequence).to be_present
      expect(entry.user).to be_present
    end

    it 'creates journal entry with realistic ABC content' do
      entry = create(:journal_entry)
      expect(entry.antecedent.length).to be >= 10
      expect(entry.behavior.length).to be >= 10
      expect(entry.consequence.length).to be >= 10
    end
  end

  describe 'data integrity' do
    it 'allows multiple entries for the same user' do
      entry1 = create(:journal_entry, user: user)
      entry2 = create(:journal_entry, user: user)
      
      expect(entry1).to be_valid
      expect(entry2).to be_valid
      expect(user.journal_entries.count).to eq(2)
    end

    it 'maintains data consistency with user deletion' do
      entry = create(:journal_entry, user: user)
      expect(entry).to be_persisted
      
      # When user is deleted, entry should be deleted (dependent: :destroy)
      expect { user.destroy }.to change(JournalEntry, :count).by(-1)
    end
  end

  describe 'ABC analysis content validation' do
    subject { build(:journal_entry, user: user) }

    it 'validates that antecedent describes environmental triggers' do
      # This is more of a content guideline test
      subject.antecedent = "Client called with urgent request at 3 PM during lunch break"
      expect(subject).to be_valid
    end

    it 'validates that behavior describes observable actions' do
      subject.behavior = "Stopped eating, answered call immediately, took detailed notes"
      expect(subject).to be_valid
    end

    it 'validates that consequence describes measurable outcomes' do
      subject.consequence = "Client expressed satisfaction, received project extension, felt stressed for 2 hours"
      expect(subject).to be_valid
    end
  end
end
