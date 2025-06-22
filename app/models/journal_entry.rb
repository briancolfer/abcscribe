class JournalEntry < ApplicationRecord
  belongs_to :user
  has_many :journal_entry_tags, dependent: :destroy
  has_many :tags, through: :journal_entry_tags
  
  validates :antecedent, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :behavior, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :consequence, presence: true, length: { minimum: 10, maximum: 1000 }
  
  # Virtual attributes for tag handling in forms
  attr_accessor :tag_ids, :new_tags
  
  def tag_ids
    @tag_ids || []
  end
  
  def new_tags
    @new_tags || []
  end
end
