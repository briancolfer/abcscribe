class Setting < ApplicationRecord
  belongs_to :user
  has_many :observations, dependent: :nullify
  has_many :subjects, -> { distinct }, through: :observations
  
  validates :name, presence: true, uniqueness: { scope: :user_id }
end

