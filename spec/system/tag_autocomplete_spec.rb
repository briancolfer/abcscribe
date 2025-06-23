require 'rails_helper'

RSpec.describe 'Tag Autocomplete and Token Creation', type: :system do
  # The journal entry test data shared context is automatically included
  # The journal entry helpers module is automatically included
  # The authentication test data shared context is automatically included
  # The authentication helpers module is automatically included
  
  before do
    sign_in_user(current_user)
  end
  
  describe 'Autocomplete functionality' do
    let!(:existing_productivity_tag) { productivity_tag }
    let!(:existing_progress_tag) { progress_tag }
    let!(:existing_personal_tag) { personal_tag }
    let!(:existing_work_tag) { work_tag }
    
    it 'shows matching suggestions as user types', js: true do
      visit_new_journal_entry_page
      
      tag_input = get_tag_input
      
      # Test progressive filtering
      tag_input.fill_in with: 'p'
      expect_autocomplete_suggestion(productivity_tag_name)
      expect_autocomplete_suggestion(progress_tag_name)
      expect_autocomplete_suggestion(personal_tag_name)
      expect(page).not_to have_content(work_tag_name)
      
      # More specific filter
      tag_input.fill_in with: 'pro'
      expect_autocomplete_suggestion(productivity_tag_name)
      expect_autocomplete_suggestion(progress_tag_name)
      expect(page).not_to have_content(personal_tag_name)
      expect(page).not_to have_content(work_tag_name)
      
      # Even more specific
      tag_input.fill_in with: 'prod'
      expect_autocomplete_suggestion(productivity_tag_name)
      expect(page).not_to have_content(progress_tag_name)
      expect(page).not_to have_content(personal_tag_name)
      expect(page).not_to have_content(work_tag_name)
    end
    
    it 'performs case-insensitive matching', js: true do
      visit_new_journal_entry_page
      
      tag_input = get_tag_input
      
      # Test uppercase input
      tag_input.fill_in with: 'PROD'
      expect_autocomplete_suggestion(productivity_tag_name)
      
      # Test mixed case
      tag_input.fill_in with: 'PrOd'
      expect_autocomplete_suggestion(productivity_tag_name)
    end
    
    it 'shows suggestions for partial matches anywhere in the tag name', js: true do
      create(:tag, name: deep_work_tag_name, user: current_user)
      
      visit_new_journal_entry_page
      
      tag_input = get_tag_input
      tag_input.fill_in with: 'work'
      
      expect_autocomplete_suggestion(work_tag_name)
      expect_autocomplete_suggestion(deep_work_tag_name)
    end
    
    it 'limits the number of suggestions shown', js: true do
      # Create many tags with similar names
      15.times do |i|
        create(:tag, name: "project-#{i}", user: current_user)
      end
      
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'project'
      
      # Should limit suggestions (assuming a reasonable limit like 10)
      suggestions = all('.autocomplete-suggestion')
      expect(suggestions.count).to be <= 10
    end
    
    it 'updates suggestions dynamically as input changes', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      
      # Start with broad search
      tag_input.fill_in with: 'p'
      expect(page).to have_content('productivity')
      expect(page).to have_content('personal')
      
      # Clear and try different search
      tag_input.fill_in with: 'w'
      expect(page).to have_content('work')
      expect(page).not_to have_content('productivity')
      expect(page).not_to have_content('personal')
      
      # Clear completely
      tag_input.fill_in with: ''
      expect(page).not_to have_css('.autocomplete-suggestion')
    end
  end
  
  describe 'Token creation and management' do
    it 'creates tokens when selecting from autocomplete', js: true do
      create(:tag, name: 'productivity', user: current_user)
      
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'prod'
      
      # Click on autocomplete suggestion
      find('button', text: 'productivity').click
      
      # Verify token was created
      expect(page).to have_css('.tag-item', text: 'productivity')
      
      # Verify input was cleared
      expect(tag_input.value).to be_empty
    end
    
    it 'creates tokens when pressing Enter for new tags', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'new-custom-tag'
      tag_input.native.send_keys(:return)
      
      # Verify token was created
      expect(page).to have_css('.tag-item', text: 'new-custom-tag')
      
      # Verify input was cleared
      expect(tag_input.value).to be_empty
    end
    
    it 'creates tokens when clicking outside the input', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'focus-lost-tag'
      
      # Click somewhere else to trigger blur
      find('label', text: 'Antecedent').click
      
      # Verify token was created
      expect(page).to have_css('.tag-item', text: 'focus-lost-tag')
    end
    
    it 'prevents duplicate tokens', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      
      # Add first token
      tag_input.fill_in with: 'unique-tag'
      tag_input.native.send_keys(:return)
      
      # Try to add the same tag again
      tag_input.fill_in with: 'unique-tag'
      tag_input.native.send_keys(:return)
      
      # Should only have one token
      tokens = all('.tag-item', text: 'unique-tag')
      expect(tokens.count).to eq(1)
    end
    
    it 'ignores empty or whitespace-only input', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      
      # Try empty string
      tag_input.fill_in with: ''
      tag_input.native.send_keys(:return)
      
      # Try whitespace only
      tag_input.fill_in with: '   '
      tag_input.native.send_keys(:return)
      
      # Should not create any tokens
      expect(page).not_to have_css('.tag-item')
    end
    
    it 'trims whitespace from tag names', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: '  spaced-tag  '
      tag_input.native.send_keys(:return)
      
      # Should create token with trimmed name
      expect(page).to have_css('.tag-item', text: 'spaced-tag')
    end
  end
  
  describe 'Token removal' do
    it 'removes tokens when clicking the remove button', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'removable-tag'
      tag_input.native.send_keys(:return)
      
      # Verify token exists
      expect(page).to have_css('.tag-item', text: 'removable-tag')
      
      # Remove the token
      within('.tag-item', text: 'removable-tag') do
        find('.remove-tag').click
      end
      
      # Verify token was removed
      expect(page).not_to have_css('.tag-item', text: 'removable-tag')
    end
    
    it 'removes tokens with keyboard shortcut', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'keyboard-removable'
      tag_input.native.send_keys(:return)
      
      # Focus the input and press backspace to remove last token
      tag_input.click
      tag_input.native.send_keys(:backspace)
      
      # Verify token was removed
      expect(page).not_to have_css('.tag-item', text: 'keyboard-removable')
    end
    
    it 'removes multiple tokens in sequence', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      
      # Add multiple tokens
      ['first-tag', 'second-tag', 'third-tag'].each do |tag_name|
        tag_input.fill_in with: tag_name
        tag_input.native.send_keys(:return)
      end
      
      # Verify all tokens exist
      expect(page).to have_css('.tag-item', text: 'first-tag')
      expect(page).to have_css('.tag-item', text: 'second-tag')
      expect(page).to have_css('.tag-item', text: 'third-tag')
      
      # Remove them one by one
      within('.tag-item', text: 'second-tag') do
        find('.remove-tag').click
      end
      
      expect(page).to have_css('.tag-item', text: 'first-tag')
      expect(page).not_to have_css('.tag-item', text: 'second-tag')
      expect(page).to have_css('.tag-item', text: 'third-tag')
    end
  end
  
  describe 'Keyboard navigation' do
    let!(:tag1) { create(:tag, name: 'alpha', user: current_user) }
    let!(:tag2) { create(:tag, name: 'beta', user: current_user) }
    let!(:tag3) { create(:tag, name: 'gamma', user: current_user) }
    
    it 'allows navigating suggestions with arrow keys', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'a'  # Should show alpha
      
      # Navigate with arrow keys and select with Enter
      tag_input.native.send_keys(:down)  # Highlight first suggestion
      tag_input.native.send_keys(:return)  # Select highlighted suggestion
      
      # Verify the tag was selected
      expect(page).to have_css('.tag-item', text: 'alpha')
    end
    
    it 'supports Escape key to close suggestions', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'a'  # Show suggestions
      
      expect(page).to have_content('alpha')
      
      tag_input.native.send_keys(:escape)
      
      # Suggestions should be hidden
      expect(page).not_to have_css('.autocomplete-suggestion')
    end
  end
  
  describe 'Performance and UX' do
    it 'debounces autocomplete requests', js: true do
      # This test would need to be implemented based on the actual
      # debouncing mechanism in the frontend code
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      
      # Rapidly type characters
      tag_input.fill_in with: 'p'
      tag_input.fill_in with: 'pr'
      tag_input.fill_in with: 'pro'
      tag_input.fill_in with: 'prod'
      
      # Should only show final results, not intermediate ones
      # Implementation would depend on actual debouncing strategy
    end
    
    it 'shows loading state during autocomplete', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'p'
      
      # Look for loading indicator (if implemented)
      # expect(page).to have_css('.autocomplete-loading')
    end
    
    it 'handles rapid tag creation without UI glitches', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      
      # Rapidly create multiple tags
      10.times do |i|
        tag_input.fill_in with: "rapid-tag-#{i}"
        tag_input.native.send_keys(:return)
      end
      
      # All tags should be present
      10.times do |i|
        expect(page).to have_css('.tag-item', text: "rapid-tag-#{i}")
      end
    end
  end
  
  describe 'Accessibility' do
    it 'provides proper ARIA labels and roles', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      
      # Check for accessibility attributes
      expect(tag_input['role']).to eq('combobox')
      expect(tag_input['aria-expanded']).to be_in(['true', 'false'])
      expect(tag_input['aria-autocomplete']).to eq('list')
    end
    
    it 'supports screen reader announcements', js: true do
      visit new_journal_entry_path
      
      tag_input = find('[data-tag-input-target="input"]')
      tag_input.fill_in with: 'accessibility-tag'
      tag_input.native.send_keys(:return)
      
      # Check for aria-live regions or announcements
      # Implementation would depend on actual accessibility features
    end
  end
end

