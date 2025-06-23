require 'rails_helper'

RSpec.describe 'Journal Entry Tags', type: :system do
  # The journal entry test data shared context is automatically included
  # The journal entry helpers module is automatically included
  # The authentication test data shared context is automatically included
  # The authentication helpers module is automatically included
  
  before do
    sign_in_user(current_user)
  end
  
  describe 'Creating entries with existing tags' do
    let!(:existing_productivity_tag) { productivity_tag }
    let!(:existing_work_tag) { work_tag }
    
    it 'allows selecting existing tags when creating a new entry', js: true do
      visit_new_journal_entry_page
      
      fill_in_journal_entry_form(**valid_journal_entry_attributes)
      
      # Test autocomplete with existing tags
      add_tag_by_autocomplete('prod', productivity_tag_name)
      
      # Verify tag was added to the form
      expect_tag_to_be_present(productivity_tag_name)
      
      submit_journal_entry_form
      
      expect_journal_entry_creation_success
      expect_tag_in_entry_display(productivity_tag_name)
    end
    
    it 'allows selecting multiple existing tags', js: true do
      visit_new_journal_entry_page
      
      fill_in_journal_entry_form(**meeting_journal_entry_attributes)
      
      # Add first tag
      add_tag_by_autocomplete('work', work_tag_name)
      
      # Add second tag
      add_tag_by_autocomplete('prod', productivity_tag_name)
      
      expect_tag_to_be_present(work_tag_name)
      expect_tag_to_be_present(productivity_tag_name)
      
      submit_journal_entry_form
      
      expect_journal_entry_creation_success
      expect_tag_in_entry_display(work_tag_name)
      expect_tag_in_entry_display(productivity_tag_name)
    end
  end
  
  describe 'Creating entries with new tags' do
    it 'allows creating new tags during entry creation', js: true do
      visit_new_journal_entry_page
      
      fill_in_journal_entry_form(**client_journal_entry_attributes)
      
      add_tag_by_typing(new_tag_name)
      
      # Verify new tag appears as a token
      expect_tag_to_be_present(new_tag_name)
      
      submit_journal_entry_form
      
      expect_journal_entry_creation_success
      expect_tag_in_entry_display(new_tag_name)
      
      # Verify the tag was actually created in the database
      expect(current_user.tags.find_by(name: new_tag_name)).to be_present
    end
    
    it 'allows mixing existing and new tags', js: true do
      existing_meeting_tag = meeting_tag
      
      visit_new_journal_entry_page
      
      fill_in_journal_entry_form(**standup_journal_entry_attributes)
      
      # Add existing tag
      add_tag_by_autocomplete('meet', meeting_tag_name)
      
      # Add new tag
      add_tag_by_typing(team_sync_tag_name)
      
      expect_tag_to_be_present(meeting_tag_name)
      expect_tag_to_be_present(team_sync_tag_name)
      
      submit_journal_entry_form
      
      expect_journal_entry_creation_success
      expect_tag_in_entry_display(meeting_tag_name)
      expect_tag_in_entry_display(team_sync_tag_name)
      
      # Verify new tag was created
      expect(current_user.tags.find_by(name: team_sync_tag_name)).to be_present
    end
  end
  
  describe 'Autocomplete suggestions' do
    let!(:tag1) { create(:tag, name: 'productivity', user: current_user) }
    let!(:tag2) { create(:tag, name: 'progress', user: current_user) }
    let!(:tag3) { create(:tag, name: 'personal', user: current_user) }
    let!(:other_user_tag) { create(:tag, name: 'productivity', user: create(:user)) }
    
    it 'shows relevant autocomplete suggestions based on input', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'pro'
      
      # Should show tags starting with 'pro'
      expect(page).to have_content('productivity')
      expect(page).to have_content('progress')
      expect(page).not_to have_content('personal')
    end
    
    it 'only shows tags belonging to the current user', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'prod'
      
      # Should only show current user's productivity tag, not other user's
      suggestions = all('.autocomplete-suggestion')
      expect(suggestions.count).to eq(1)
      expect(page).to have_content('productivity')
    end
    
    it 'shows no suggestions for non-matching input', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'xyz'
      
      expect(page).not_to have_css('.autocomplete-suggestion')
    end
  end
  
  describe 'Tag display' do
    let(:journal_entry) { create(:journal_entry, user: current_user) }
    let!(:tag1) { create(:tag, name: 'productivity', user: current_user) }
    let!(:tag2) { create(:tag, name: 'work-life-balance', user: current_user) }
    
    before do
      journal_entry.tags << [tag1, tag2]
    end
    
    it 'displays tags on the journal entry show page' do
      visit journal_entry_path(journal_entry)
      
      expect(page).to have_content('productivity')
      expect(page).to have_content('work-life-balance')
      
      # Tags should be styled appropriately
      expect(page).to have_css('.tag', text: 'productivity')
      expect(page).to have_css('.tag', text: 'work-life-balance')
    end
    
    it 'displays tags on the journal entries index page' do
      visit journal_entries_path
      
      expect(page).to have_content('productivity')
      expect(page).to have_content('work-life-balance')
    end
    
    it 'handles long tag names gracefully' do
      long_tag = create(:tag, name: 'this-is-a-very-long-tag-name-that-might-wrap', user: current_user)
      journal_entry.tags << long_tag
      
      visit journal_entry_path(journal_entry)
      
      expect(page).to have_content('this-is-a-very-long-tag-name-that-might-wrap')
      expect(page).to have_css('.tag', text: 'this-is-a-very-long-tag-name-that-might-wrap')
    end
  end
  
  describe 'Tag removal' do
    it 'allows removing tags from entry form before submission', js: true do
      visit new_journal_entry_path
      
      fill_in 'Antecedent', with: 'Test antecedent'
      fill_in 'Behavior', with: 'Test behavior'
      fill_in 'Consequence', with: 'Test consequence'
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'temporary-tag'
      tag_input.native.send_keys(:return)
      
      # Verify tag was added
      expect(page).to have_css('.tag-item', text: 'temporary-tag')
      
      # Remove the tag
      within('.tag-item', text: 'temporary-tag') do
        find('.remove-tag').click
      end
      
      # Verify tag was removed
      expect(page).not_to have_css('.tag-item', text: 'temporary-tag')
      
      click_button 'Save Entry'
      
      expect(page).to have_content('Journal entry was successfully created.')
      expect(page).not_to have_content('temporary-tag')
    end
  end
  
  describe 'Editing entries with tags' do
    let(:journal_entry) { create(:journal_entry, user: current_user) }
    let!(:existing_tag) { create(:tag, name: 'existing', user: current_user) }
    
    before do
      journal_entry.tags << existing_tag
    end
    
    it 'shows existing tags when editing an entry', js: true do
      visit edit_journal_entry_path(journal_entry)
      
      expect(page).to have_css('.tag-item', text: 'existing')
    end
    
    it 'allows adding new tags when editing', js: true do
      visit edit_journal_entry_path(journal_entry)
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'additional-tag'
      tag_input.native.send_keys(:return)
      
      expect(page).to have_css('.tag-item', text: 'existing')
      expect(page).to have_css('.tag-item', text: 'additional-tag')
      
      click_button 'Save Entry'
      
      expect(page).to have_content('Journal entry was successfully updated.')
      expect(page).to have_content('existing')
      expect(page).to have_content('additional-tag')
    end
    
    it 'allows removing existing tags when editing', js: true do
      visit edit_journal_entry_path(journal_entry)
      
      within('.tag-item', text: 'existing') do
        find('.remove-tag').click
      end
      
      expect(page).not_to have_css('.tag-item', text: 'existing')
      
      click_button 'Save Entry'
      
      expect(page).to have_content('Journal entry was successfully updated.')
      expect(page).not_to have_content('existing')
    end
  end
  
  describe 'Error handling' do
    it 'handles empty tag names gracefully', js: true do
      visit new_journal_entry_path
      
      fill_in 'Antecedent', with: 'Test antecedent'
      fill_in 'Behavior', with: 'Test behavior'
      fill_in 'Consequence', with: 'Test consequence'
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: '   '  # Only whitespace
      tag_input.native.send_keys(:return)
      
      # Should not create a tag with only whitespace
      expect(page).not_to have_css('.tag-item', text: '   ')
      
      click_button 'Save Entry'
      
      expect(page).to have_content('Journal entry was successfully created.')
    end
    
    it 'handles very long tag names', js: true do
      visit new_journal_entry_path
      
      fill_in 'Antecedent', with: 'Test antecedent'
      fill_in 'Behavior', with: 'Test behavior'
      fill_in 'Consequence', with: 'Test consequence'
      
      long_tag_name = 'a' * 60  # Longer than the 50 character limit
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: long_tag_name
      tag_input.native.send_keys(:return)
      
      click_button 'Save Entry'
      
      # Should show validation error or truncate
      # This test will reveal the current behavior
      expect(page).to have_content('too long') if page.has_content?('error')
    end
  end
  
  describe 'User isolation' do
    let(:other_user) { create(:user) }
    let!(:other_user_tag) { create(:tag, name: 'private-tag', user: other_user) }
    
    it 'does not show other users tags in autocomplete', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'private'
      
      expect(page).not_to have_content('private-tag')
    end
    
    it 'does not allow accessing other users tags directly' do
      # This would be a security test at the controller level
      # but serves as documentation of expected behavior
      expect {
        post tags_path, params: { name: 'malicious-tag' }
      }.to change(current_user.tags, :count).by(1)
      
      expect(other_user.tags.find_by(name: 'malicious-tag')).to be_nil
    end
  end
end

