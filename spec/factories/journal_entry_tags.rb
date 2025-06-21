FactoryBot.define do
  factory :journal_entry_tag do
    journal_entry
    tag
    
    # Ensure the tag belongs to the same user as the journal entry
    after(:build) do |journal_entry_tag|
      if journal_entry_tag.tag.present? && journal_entry_tag.journal_entry.present?
        journal_entry_tag.tag.user = journal_entry_tag.journal_entry.user
      end
    end
  end
end
