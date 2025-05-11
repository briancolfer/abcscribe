class Observation < ApplicationRecord
  belongs_to :user
  belongs_to :subject
  belongs_to :setting, optional: true
  
  validates :observed_at, presence: true
  validates :antecedent, presence: true
  validates :behavior, presence: true
  validates :consequence, presence: true

  validate :observed_at_not_in_future
  
  paginates_per 10

  private

  def observed_at_not_in_future
    if observed_at.present? && observed_at > Time.current
      errors.add(:observed_at, "cannot be in the future")
    end
  end
end
