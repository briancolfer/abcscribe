class JournalEntry < ApplicationRecord
  belongs_to :user
  
  validates :antecedent, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :behavior, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :consequence, presence: true, length: { minimum: 10, maximum: 1000 }
end
