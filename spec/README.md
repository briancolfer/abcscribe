# Test Suite Documentation

This document describes the comprehensive RSpec test suite for the Tag system in the ABC Journal application.

## Model Tests

### Tag Model (`spec/models/tag_spec.rb`)

Comprehensive tests covering:

**Validations:**
- Name presence requirement
- Name length limit (50 characters)
- Uniqueness per user
- Case sensitivity
- Whitespace handling

**Associations:**
- Belongs to user
- Has many journal_entry_tags (with dependent: :destroy)
- Has many journal_entries through journal_entry_tags
- Proper deletion behavior

**Scopes and Queries:**
- User-specific tag retrieval
- Name normalization behavior

### JournalEntryTag Model (`spec/models/journal_entry_tag_spec.rb`)

Tests covering:

**Associations:**
- Belongs to journal_entry
- Belongs to tag
- Required associations

**Uniqueness Constraints:**
- Multiple tags per journal entry
- Same tag across multiple entries
- Duplicate prevention (documented behavior)

**Data Consistency:**
- Cross-user tagging behavior
- Deletion cascading

**Factory Validation:**
- Proper factory setup
- User consistency between associations

## System/Feature Tests

### Journal Entry Tags (`spec/system/journal_entry_tags_spec.rb`)

End-to-end tests using Capybara covering:

**Creating Entries with Existing Tags:**
- Autocomplete functionality
- Multiple tag selection
- UI interaction flow

**Creating Entries with New Tags:**
- New tag creation during entry creation
- Mixed existing/new tag scenarios
- Database persistence verification

**Tag Display:**
- Tag rendering on show pages
- Tag rendering on index pages
- Long tag name handling

**Tag Management:**
- Tag removal from forms
- Editing entries with tags
- Tag addition/removal during editing

**Error Handling:**
- Empty tag name handling
- Long tag name validation
- UI error states

**User Isolation:**
- Security testing for cross-user access
- Autocomplete filtering by user

### Tag Autocomplete (`spec/system/tag_autocomplete_spec.rb`)

Focused tests for the tag input component:

**Autocomplete Functionality:**
- Progressive filtering
- Case-insensitive matching
- Partial matching
- Suggestion limiting
- Dynamic updates

**Token Creation and Management:**
- Selection from autocomplete
- Enter key creation
- Blur event creation
- Duplicate prevention
- Input validation

**Token Removal:**
- Click-to-remove functionality
- Keyboard shortcuts
- Multiple token management

**Keyboard Navigation:**
- Arrow key navigation
- Escape key handling
- Enter key selection

**Performance and UX:**
- Debouncing (documented for implementation)
- Loading states
- Rapid interaction handling

**Accessibility:**
- ARIA labels and roles
- Screen reader support

## Factories

Enhanced factories with realistic data:

- **Tags:** Multiple traits (work, personal), with journal entries
- **JournalEntryTags:** Proper user consistency
- **Users:** Realistic test data
- **JournalEntries:** Comprehensive ABC format

## Setup Requirements

### Dependencies
- RSpec Rails 7.0+
- FactoryBot Rails
- Faker
- Capybara
- Selenium WebDriver

### Configuration
- Devise test helpers for all spec types
- Warden helpers for system tests
- Chrome headless driver for JavaScript tests

## Running Tests

```bash
# All model tests
bundle exec rspec spec/models/

# Tag-specific model tests
bundle exec rspec spec/models/tag_spec.rb
bundle exec rspec spec/models/journal_entry_tag_spec.rb

# System tests (requires JavaScript driver setup)
bundle exec rspec spec/system/

# Specific system test suites
bundle exec rspec spec/system/journal_entry_tags_spec.rb
bundle exec rspec spec/system/tag_autocomplete_spec.rb
```

## Notes

- JavaScript tests require proper Selenium WebDriver setup
- System tests may need additional configuration for CI environments
- Some tests document expected behavior that may need implementation
- Accessibility tests provide guidelines for implementation
- Performance tests suggest areas for optimization

## Coverage

The test suite provides comprehensive coverage of:
- ✅ Model validations and associations
- ✅ Database constraints and relationships
- ✅ User interface interactions
- ✅ JavaScript functionality
- ✅ Error handling and edge cases
- ✅ Security and user isolation
- ✅ Accessibility considerations
- ✅ Performance implications

