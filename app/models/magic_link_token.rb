class MagicLinkToken < ApplicationRecord
  belongs_to :user
  before_validation :generate_unique_token, on: :create
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  def expired?
    Time.current > expires_at
  end

  private

  def generate_unique_token
    self.token ||= SecureRandom.urlsafe_base64(24)
    self.expires_at = 15.minutes.from_now
  end
end