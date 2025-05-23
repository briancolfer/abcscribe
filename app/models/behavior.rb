class Behavior < ApplicationRecord
  belongs_to :user
  has_many :journal_entries, dependent: :nullify
  
  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id }
end

