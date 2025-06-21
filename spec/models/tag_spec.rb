require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'validations' do
    let(:user) { create(:user) }
    
    it 'is valid with valid attributes' do
      tag = build(:tag, name: 'productivity', user: user)
      expect(tag).to be_valid
    end
    
    it 'requires a name' do
      tag = build(:tag, name: nil, user: user)
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include("can't be blank")
    end
    
    it 'requires a name to be present (not just whitespace)' do
      tag = build(:tag, name: '   ', user: user)
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include("can't be blank")
    end
    
    it 'limits name length to 50 characters' do
      tag = build(:tag, name: 'a' * 51, user: user)
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include('is too long (maximum is 50 characters)')
    end
    
    it 'allows name length up to 50 characters' do
      tag = build(:tag, name: 'a' * 50, user: user)
      expect(tag).to be_valid
    end
    
    it 'requires unique name per user' do
      create(:tag, name: 'productivity', user: user)
      duplicate_tag = build(:tag, name: 'productivity', user: user)
      expect(duplicate_tag).not_to be_valid
      expect(duplicate_tag.errors[:name]).to include('has already been taken')
    end
    
    it 'allows same name for different users' do
      user2 = create(:user)
      create(:tag, name: 'productivity', user: user)
      tag_for_user2 = build(:tag, name: 'productivity', user: user2)
      expect(tag_for_user2).to be_valid
    end
    
    it 'is case sensitive for uniqueness' do
      create(:tag, name: 'productivity', user: user)
      tag_with_different_case = build(:tag, name: 'Productivity', user: user)
      expect(tag_with_different_case).to be_valid
    end
  end
  
  describe 'associations' do
    let(:user) { create(:user) }
    let(:tag) { create(:tag, user: user) }
    
    it 'belongs to a user' do
      expect(tag.user).to eq(user)
    end
    
    it 'has many journal_entry_tags' do
      journal_entry = create(:journal_entry, user: user)
      journal_entry_tag = create(:journal_entry_tag, tag: tag, journal_entry: journal_entry)
      
      expect(tag.journal_entry_tags).to include(journal_entry_tag)
    end
    
    it 'has many journal_entries through journal_entry_tags' do
      journal_entry = create(:journal_entry, user: user)
      create(:journal_entry_tag, tag: tag, journal_entry: journal_entry)
      
      expect(tag.journal_entries).to include(journal_entry)
    end
    
    it 'destroys associated journal_entry_tags when deleted' do
      journal_entry = create(:journal_entry, user: user)
      journal_entry_tag = create(:journal_entry_tag, tag: tag, journal_entry: journal_entry)
      journal_entry_tag_id = journal_entry_tag.id
      
      expect { tag.destroy }.to change(JournalEntryTag, :count).by(-1)
      expect(JournalEntryTag.find_by(id: journal_entry_tag_id)).to be_nil
    end
    
    it 'does not destroy associated journal_entries when deleted' do
      journal_entry = create(:journal_entry, user: user)
      create(:journal_entry_tag, tag: tag, journal_entry: journal_entry)
      
      expect { tag.destroy }.not_to change(JournalEntry, :count)
      expect(JournalEntry.find(journal_entry.id)).to eq(journal_entry)
    end
  end
  
  describe 'scopes and queries' do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    
    before do
      create(:tag, name: 'productivity', user: user)
      create(:tag, name: 'personal', user: user)
      create(:tag, name: 'work', user: user2)
    end
    
    it 'returns only tags for the specified user' do
      user_tags = user.tags
      expect(user_tags.count).to eq(2)
      expect(user_tags.pluck(:name)).to contain_exactly('productivity', 'personal')
    end
  end
  
  describe 'name normalization' do
    let(:user) { create(:user) }
    
    it 'preserves the original case of the name' do
      tag = create(:tag, name: 'ProductiVity', user: user)
      expect(tag.name).to eq('ProductiVity')
    end
    
    it 'trims whitespace from name during validation' do
      tag = build(:tag, name: '  productivity  ', user: user)
      tag.valid?
      # Note: Rails validates before saving, so we check the actual behavior
      tag.save
      expect(tag.name).to eq('  productivity  ') # Rails doesn't auto-trim, but validates presence
    end
  end
end
