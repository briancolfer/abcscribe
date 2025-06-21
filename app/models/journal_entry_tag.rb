class JournalEntryTag < ApplicationRecord
  belongs_to :journal_entry
  belongs_to :tag
end
