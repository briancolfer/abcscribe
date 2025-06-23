RSpec.shared_context "journal entry test data" do
  # Sample journal entry content
  let(:valid_antecedent) { "Manager assigned urgent project" }
  let(:valid_behavior) { "Created priority list and timeline" }
  let(:valid_consequence) { "Project completed on schedule" }
  
  # Alternative journal entry content for variety
  let(:meeting_antecedent) { "Team meeting scheduled" }
  let(:meeting_behavior) { "Prepared agenda and materials" }
  let(:meeting_consequence) { "Meeting ran efficiently" }
  
  let(:client_antecedent) { "Client called with new requirements" }
  let(:client_behavior) { "Documented requirements and created plan" }
  let(:client_consequence) { "Client approved approach" }
  
  let(:standup_antecedent) { "Daily standup started" }
  let(:standup_behavior) { "Shared progress and blocked items" }
  let(:standup_consequence) { "Team aligned on priorities" }
  
  # Complete valid journal entry attributes
  let(:valid_journal_entry_attributes) do
    {
      antecedent: valid_antecedent,
      behavior: valid_behavior,
      consequence: valid_consequence
    }
  end
  
  let(:meeting_journal_entry_attributes) do
    {
      antecedent: meeting_antecedent,
      behavior: meeting_behavior,
      consequence: meeting_consequence
    }
  end
  
  let(:client_journal_entry_attributes) do
    {
      antecedent: client_antecedent,
      behavior: client_behavior,
      consequence: client_consequence
    }
  end
  
  let(:standup_journal_entry_attributes) do
    {
      antecedent: standup_antecedent,
      behavior: standup_behavior,
      consequence: standup_consequence
    }
  end
  
  # Invalid journal entry data for error testing
  let(:blank_antecedent) { "" }
  let(:blank_behavior) { "" }
  let(:blank_consequence) { "" }
  
  let(:too_long_text) { "a" * 2001 } # Assuming 2000 char limit
  
  let(:invalid_journal_entry_blank_antecedent) do
    {
      antecedent: blank_antecedent,
      behavior: valid_behavior,
      consequence: valid_consequence
    }
  end
  
  let(:invalid_journal_entry_blank_behavior) do
    {
      antecedent: valid_antecedent,
      behavior: blank_behavior,
      consequence: valid_consequence
    }
  end
  
  let(:invalid_journal_entry_blank_consequence) do
    {
      antecedent: valid_antecedent,
      behavior: valid_behavior,
      consequence: blank_consequence
    }
  end
  
  # Tag-related test data
  let(:productivity_tag_name) { "productivity" }
  let(:work_tag_name) { "work" }
  let(:meeting_tag_name) { "meeting" }
  let(:personal_tag_name) { "personal" }
  let(:progress_tag_name) { "progress" }
  
  # New tag names for testing creation
  let(:new_tag_name) { "client-communication" }
  let(:team_sync_tag_name) { "team-sync" }
  let(:deep_work_tag_name) { "deep-work" }
  
  # Long tag name for testing edge cases
  let(:long_tag_name) { "this-is-a-very-long-tag-name-that-might-wrap" }
  
  # Invalid tag names
  let(:blank_tag_name) { "" }
  let(:whitespace_tag_name) { "   " }
  let(:spaced_tag_name) { "  spaced-tag  " }
  let(:trimmed_tag_name) { "spaced-tag" }
  
  # Factory-based data
  let(:journal_entry_from_factory) { create(:journal_entry, user: current_user) }
  let(:journal_entry_attributes_from_factory) { attributes_for(:journal_entry) }
  
  # User with tags for testing
  let(:user_with_tags) { create(:user) }
  let(:productivity_tag) { create(:tag, name: productivity_tag_name, user: user_with_tags) }
  let(:work_tag) { create(:tag, name: work_tag_name, user: user_with_tags) }
  let(:meeting_tag) { create(:tag, name: meeting_tag_name, user: user_with_tags) }
  let(:personal_tag) { create(:tag, name: personal_tag_name, user: user_with_tags) }
  let(:progress_tag) { create(:tag, name: progress_tag_name, user: user_with_tags) }
  
  # Helper for creating journal entry with tags
  let(:journal_entry_with_tags) do
    entry = create(:journal_entry, user: user_with_tags)
    entry.tags << [productivity_tag, work_tag]
    entry
  end
  
  # Multiple journal entries for testing lists
  let(:journal_entries_list) do
    [
      create(:journal_entry, user: user_with_tags, **valid_journal_entry_attributes),
      create(:journal_entry, user: user_with_tags, **meeting_journal_entry_attributes),
      create(:journal_entry, user: user_with_tags, **client_journal_entry_attributes)
    ]
  end
  
  # Default test user (can be overridden in specs)
  let(:current_user) { user_with_tags }
end

# Auto-include in system specs
RSpec.configure do |config|
  config.include_context "journal entry test data", type: :system
end
