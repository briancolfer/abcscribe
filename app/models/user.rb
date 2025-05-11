class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, 
                   uniqueness: { case_sensitive: false },
                   format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :name, presence: true
  validates :password, presence: true, 
                      length: { minimum: 8 }, 
                      allow_nil: true
  validates :api_token, uniqueness: true, allow_nil: true

  # Converts email to lowercase before saving
  before_save :downcase_email
  
  # Remember token methods
  def remember
    self.remember_token = User.generate_token
    self.remember_created_at = Time.current
    update_columns(remember_token: remember_token, 
                  remember_created_at: remember_created_at)
  end
  
  def forget
    update_columns(remember_token: nil, 
                  remember_created_at: nil)
  end
  
  def remembered?
    remember_token.present? && 
    remember_created_at.present? && 
    remember_created_at > 2.weeks.ago
  end
  
  # Class methods
  def self.generate_token
    SecureRandom.urlsafe_base64(24)
  end
  
  # API token methods
  def generate_api_token
    return api_token if api_token.present?

    loop do
      token = JsonWebToken.encode({ user_id: id })
      self.api_token = token
      break unless User.exists?(api_token: token)
    end

    save!
    api_token
  end

  def invalidate_token
    update_column(:api_token, nil)
  end

  def token_valid?
    api_token.present? && JsonWebToken.decode(api_token)[:user_id] == id
  rescue JWT::DecodeError
    false
  end
  
  private
  
  def downcase_email
    self.email = email.downcase
  end
  
  # Associations for ABCScribe
  has_many :subjects, dependent: :destroy
  has_many :settings, dependent: :destroy
  has_many :observations, dependent: :destroy
end
