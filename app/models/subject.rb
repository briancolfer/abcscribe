class Subject < ApplicationRecord
  belongs_to :user
  has_many :observations, dependent: :destroy
  has_many :settings, through: :observations

  validates :name, presence: true
  validate :date_of_birth_not_in_future, if: -> { date_of_birth.present? }

  scope :search_by_name, ->(query) { 
    where("name LIKE ?", "%#{sanitize_sql_like(query)}%") if query.present?
  }
  
  scope :with_dob_between, ->(start_date, end_date) {
    return unless start_date.present? && end_date.present?
    
    start_date = start_date.to_date rescue nil
    end_date = end_date.to_date rescue nil
    return unless start_date && end_date

    where(
      "date_of_birth >= ? AND date_of_birth <= ?",
      start_date,
      end_date
    )
  }

  scope :with_observation_count, ->(min_count) {
    if min_count.present?
      left_joins(:observations)
        .group('subjects.id')
        .having('COUNT(observations.id) >= ?', min_count.to_i)
    end
  }

  scope :order_by_field, ->(field, direction = :asc) {
    direction = %w[asc desc].include?(direction.to_s) ? direction : :asc

    case field&.to_sym
    when :name
      # Use case-insensitive sorting
      order("LOWER(name) #{direction}")
    when :date_of_birth
      order(Arel.sql("COALESCE(date_of_birth, '9999-12-31') #{direction}"))
    when :observations_count
      left_joins(:observations)
        .group('subjects.id')
        .order(Arel.sql("COUNT(observations.id) #{direction}"))
    else
      order(created_at: :desc)
    end
  }

  def self.sanitize_sql_like(string)
    string.to_s.gsub(/[\\%_]/) { |m| "\\#{m}" }
  end

  def observations_count
    observations.count
  end

  private

  def date_of_birth_not_in_future
    if date_of_birth.present? && date_of_birth > Date.current
      errors.add(:date_of_birth, "must be in the past")
    end
  end
end

