class JournalEntry < ApplicationRecord
  belongs_to :user
  has_many :journal_entry_tags, dependent: :destroy
  has_many :tags, through: :journal_entry_tags
  
  validates :antecedent, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :behavior, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :consequence, presence: true, length: { minimum: 6, maximum: 1000 }
  validate :valid_consequence_content

  # Virtual attributes for tag handling in forms
  attr_accessor :tag_ids, :new_tags
  
  def tag_ids
    @tag_ids || []
  end
  
  def new_tags
    @new_tags || []
  end

  private

  def valid_consequence_content
    if consequence.present?
      if consequence.downcase == "unknown"
        return
      elsif consequence.length < 10
        errors.add(:consequence, "must be at least 10 characters unless it is 'unknown'")
      elsif consequence.downcase.include?("don't know") || consequence.match?(/^unknown\s?.*/)
        errors.add(:consequence, "use the word 'unknown' only if the consequence is unknown")
      end
    end
  end
end
