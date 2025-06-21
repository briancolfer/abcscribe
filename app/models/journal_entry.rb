class JournalEntry < ApplicationRecord
  belongs_to :user
  has_many :journal_entry_tags, dependent: :destroy
  has_many :tags, through: :journal_entry_tags
  
  validates :antecedent, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :behavior, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :consequence, presence: true, length: { minimum: 10, maximum: 1000 }
end
