class JournalEntry < ApplicationRecord
  belongs_to :user
  belongs_to :behavior
  
  validates :occurred_at, presence: true
  validates :behavior, presence: true
  validates :consequence, presence: true
  
  enum :reinforcement_type, { positive: 0, negative: 1, neutral: 2 }
end

