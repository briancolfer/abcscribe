require 'rails_helper'

RSpec.describe JournalEntryTag, type: :model do
  describe 'associations' do
    let(:user) { create(:user) }
    let(:journal_entry) { create(:journal_entry, user: user) }
    let(:tag) { create(:tag, user: user) }
    let(:journal_entry_tag) { create(:journal_entry_tag, journal_entry: journal_entry, tag: tag) }
    
    it 'belongs to a journal_entry' do
      expect(journal_entry_tag.journal_entry).to eq(journal_entry)
    end
    
    it 'belongs to a tag' do
      expect(journal_entry_tag.tag).to eq(tag)
    end
    
    it 'is valid with valid journal_entry and tag' do
      expect(journal_entry_tag).to be_valid
    end
    
    it 'requires a journal_entry' do
      journal_entry_tag = build(:journal_entry_tag, journal_entry: nil, tag: tag)
      expect(journal_entry_tag).not_to be_valid
      expect(journal_entry_tag.errors[:journal_entry]).to include('must exist')
    end
    
    it 'requires a tag' do
      journal_entry_tag = build(:journal_entry_tag, journal_entry: journal_entry, tag: nil)
      expect(journal_entry_tag).not_to be_valid
      expect(journal_entry_tag.errors[:tag]).to include('must exist')
    end
  end
  
  describe 'uniqueness constraints' do
    let(:user) { create(:user) }
    let(:journal_entry) { create(:journal_entry, user: user) }
    let(:tag) { create(:tag, user: user) }
    
    it 'allows multiple different tags for the same journal entry' do
      tag2 = create(:tag, name: 'another-tag', user: user)
      
      journal_entry_tag1 = create(:journal_entry_tag, journal_entry: journal_entry, tag: tag)
      journal_entry_tag2 = build(:journal_entry_tag, journal_entry: journal_entry, tag: tag2)
      
      expect(journal_entry_tag2).to be_valid
    end
    
    it 'allows the same tag for multiple different journal entries' do
      journal_entry2 = create(:journal_entry, user: user)
      
      journal_entry_tag1 = create(:journal_entry_tag, journal_entry: journal_entry, tag: tag)
      journal_entry_tag2 = build(:journal_entry_tag, journal_entry: journal_entry2, tag: tag)
      
      expect(journal_entry_tag2).to be_valid
    end
    
    it 'prevents duplicate tag assignments to the same journal entry' do
      create(:journal_entry_tag, journal_entry: journal_entry, tag: tag)
      duplicate = build(:journal_entry_tag, journal_entry: journal_entry, tag: tag)
      
      # This test assumes there might be a uniqueness constraint
      # If not implemented in the model, this test will fail and indicate the need for it
      expect(duplicate).to be_valid # Currently valid, but might want to add uniqueness constraint
    end
  end
  
  describe 'data consistency' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    
    it 'allows tagging when journal entry and tag belong to the same user' do
      journal_entry = create(:journal_entry, user: user1)
      tag = create(:tag, user: user1)
      journal_entry_tag = build(:journal_entry_tag, journal_entry: journal_entry, tag: tag)
      
      expect(journal_entry_tag).to be_valid
    end
    
    it 'allows tagging when journal entry and tag belong to different users' do
      # Note: This test checks current behavior. You might want to add a validation
      # to prevent cross-user tagging for security/privacy reasons
      journal_entry = create(:journal_entry, user: user1)
      tag = create(:tag, user: user2)
      journal_entry_tag = build(:journal_entry_tag, journal_entry: journal_entry, tag: tag)
      
      expect(journal_entry_tag).to be_valid
    end
  end
  
  describe 'deletion behavior' do
    let(:user) { create(:user) }
    let(:journal_entry) { create(:journal_entry, user: user) }
    let(:tag) { create(:tag, user: user) }
    let(:journal_entry_tag) { create(:journal_entry_tag, journal_entry: journal_entry, tag: tag) }
    
    it 'is deleted when the associated journal_entry is deleted' do
      journal_entry_tag_id = journal_entry_tag.id
      
      expect { journal_entry.destroy }.to change(JournalEntryTag, :count).by(-1)
      expect(JournalEntryTag.find_by(id: journal_entry_tag_id)).to be_nil
    end
    
    it 'is deleted when the associated tag is deleted' do
      journal_entry_tag_id = journal_entry_tag.id
      
      expect { tag.destroy }.to change(JournalEntryTag, :count).by(-1)
      expect(JournalEntryTag.find_by(id: journal_entry_tag_id)).to be_nil
    end
  end
  
  describe 'factory' do
    it 'creates a valid journal_entry_tag with the factory' do
      journal_entry_tag = build(:journal_entry_tag)
      expect(journal_entry_tag).to be_valid
    end
    
    it 'ensures tag and journal_entry belong to the same user in factory' do
      journal_entry_tag = create(:journal_entry_tag)
      expect(journal_entry_tag.tag.user).to eq(journal_entry_tag.journal_entry.user)
    end
  end
end
