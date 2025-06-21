class Tag < ApplicationRecord
  belongs_to :user
  has_many :journal_entry_tags, dependent: :destroy
  has_many :journal_entries, through: :journal_entry_tags
  validates :name, presence: true, length: { maximum: 50 }, uniqueness: { scope: :user_id }
end
