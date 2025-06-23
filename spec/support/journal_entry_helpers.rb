module JournalEntryHelpers
  # Page object helper methods for journal entry actions
  
  def visit_journal_entries_index
    visit journal_entries_path
  end
  
  def visit_new_journal_entry_page
    visit new_journal_entry_path
  end
  
  def visit_journal_entry_page(journal_entry)
    visit journal_entry_path(journal_entry)
  end
  
  def visit_edit_journal_entry_page(journal_entry)
    visit edit_journal_entry_path(journal_entry)
  end
  
  # Form filling helpers
  def fill_in_journal_entry_form(antecedent:, behavior:, consequence:)
    fill_in 'Antecedent', with: antecedent
    fill_in 'Behavior', with: behavior
    fill_in 'Consequence', with: consequence
  end
  
  def fill_in_antecedent(text)
    fill_in 'Antecedent', with: text
  end
  
  def fill_in_behavior(text)
    fill_in 'Behavior', with: text
  end
  
  def fill_in_consequence(text)
    fill_in 'Consequence', with: text
  end
  
  def submit_journal_entry_form
    click_button 'Save Entry'
  end
  
  def complete_journal_entry_creation(antecedent:, behavior:, consequence:)
    visit_new_journal_entry_page
    fill_in_journal_entry_form(
      antecedent: antecedent,
      behavior: behavior,
      consequence: consequence
    )
    submit_journal_entry_form
  end
  
  # Tag-related helpers
  def add_tag_by_typing(tag_name)
    tag_input = find('[data-tag-input-target="input"]')
    tag_input.fill_in with: tag_name
    tag_input.native.send_keys(:return)
  end
  
  def add_tag_by_autocomplete(partial_name, full_name)
    tag_input = find('[data-tag-input-target="input"]')
    tag_input.fill_in with: partial_name
    find('button', text: full_name).click
  end
  
  def get_tag_input
    find('[data-tag-input-target="input"]')
  end
  
  def remove_tag(tag_name)
    within('.tag-item', text: tag_name) do
      find('.remove-tag').click
    end
  end
  
  # Expectation helpers
  def expect_journal_entry_creation_success
    expect(page).to have_content('Journal entry was successfully created.')
  end
  
  def expect_journal_entry_update_success
    expect(page).to have_content('Journal entry was successfully updated.')
  end
  
  def expect_tag_to_be_present(tag_name)
    expect(page).to have_css('.tag-item', text: tag_name)
  end
  
  def expect_tag_not_to_be_present(tag_name)
    expect(page).not_to have_css('.tag-item', text: tag_name)
  end
  
  def expect_tag_in_entry_display(tag_name)
    expect(page).to have_css('.tag', text: tag_name)
  end
  
  def expect_autocomplete_suggestion(tag_name)
    # Look specifically in the suggestions list
    suggestion_list = find('[data-tag-input-target="list"]')
    expect(suggestion_list).to have_content(tag_name)
  end
  
  def expect_no_autocomplete_suggestions
    expect(page).not_to have_css('.autocomplete-suggestion')
  end
  
  # Validation helpers
  def expect_journal_entry_error(message = nil)
    if message
      expect(page).to have_content(message)
    else
      expect(page).to have_css('.field_with_errors, .alert-danger')
    end
  end
  
  def expect_to_be_on_journal_entries_index
    expect(current_path).to eq(journal_entries_path)
    expect(page).to have_content('Journal Entries')
  end
  
  def expect_to_be_on_new_journal_entry_page
    expect(current_path).to eq(new_journal_entry_path)
    expect(page).to have_content('New Journal Entry')
  end
  
  def expect_to_be_on_journal_entry_page(journal_entry)
    expect(current_path).to eq(journal_entry_path(journal_entry))
  end
end

# Include the helper module in system specs
RSpec.configure do |config|
  config.include JournalEntryHelpers, type: :system
end
