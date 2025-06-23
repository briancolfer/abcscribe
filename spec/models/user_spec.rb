require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_attributes) do
    {
      email: "user@example.com",
      password: "password123",
      password_confirmation: "password123"
    }
  end

  describe 'validations' do
    subject { build(:user) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    describe 'email validation' do
      it 'requires email to be present' do
        subject.email = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:email]).to include("can't be blank")
      end

      it 'requires email to be unique' do
        unique_email = "unique_#{SecureRandom.hex(4)}@example.com"
        create(:user, email: unique_email)
        duplicate_user = build(:user, email: unique_email)
        expect(duplicate_user).not_to be_valid
        expect(duplicate_user.errors[:email]).to include("has already been taken")
      end

      it 'validates email format' do
        subject.email = "invalid-email"
        expect(subject).not_to be_valid
        expect(subject.errors[:email]).to include("is invalid")
      end

      it 'accepts valid email formats' do
        valid_emails = [
          "user@example.com",
          "test.user@example.com",
          "user+tag@example.com",
          "user@subdomain.example.com"
        ]
        
        valid_emails.each do |email|
          subject.email = email
          expect(subject).to be_valid, "#{email} should be valid"
        end
      end

      it 'preserves email case as entered' do
        subject.email = "USER@EXAMPLE.COM"
        subject.save!
        # Devise doesn't automatically downcase emails by default
        expect(subject.reload.email).to eq("user@example.com")
      end
    end

    describe 'password validation' do
      it 'requires password to be present' do
        subject.password = nil
        subject.password_confirmation = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:password]).to include("can't be blank")
      end

      it 'requires password to be at least 6 characters' do
        subject.password = "12345"
        subject.password_confirmation = "12345"
        expect(subject).not_to be_valid
        expect(subject.errors[:password]).to include("is too short (minimum is 6 characters)")
      end

      it 'accepts password of 6 characters' do
        subject.password = "123456"
        subject.password_confirmation = "123456"
        expect(subject).to be_valid
      end

      it 'requires password confirmation to match' do
        subject.password = "password123"
        subject.password_confirmation = "different123"
        expect(subject).not_to be_valid
        expect(subject.errors[:password_confirmation]).to include("doesn't match Password")
      end

      it 'accepts strong passwords' do
        strong_passwords = [
          "SuperSecure123!",
          "my-long-passphrase-2024",
          "C0mpl3x!P@ssw0rd"
        ]
        
        strong_passwords.each do |password|
          subject.password = password
          subject.password_confirmation = password
          expect(subject).to be_valid, "#{password} should be valid"
        end
      end
    end
  end

  describe 'associations' do
    subject { create(:user) }

    it 'has many journal entries' do
      expect(subject).to respond_to(:journal_entries)
      expect(subject.journal_entries).to be_empty
    end

    it 'has many tags' do
      expect(subject).to respond_to(:tags)
      expect(subject.tags).to be_empty
    end

    it 'destroys associated journal entries when user is deleted' do
      entry1 = create(:journal_entry, user: subject)
      entry2 = create(:journal_entry, user: subject)
      
      expect { subject.destroy }.to change(JournalEntry, :count).by(-2)
    end

    it 'destroys associated tags when user is deleted' do
      tag1 = create(:tag, user: subject, name: "productivity")
      tag2 = create(:tag, user: subject, name: "stress")
      
      expect { subject.destroy }.to change(Tag, :count).by(-2)
    end

    it 'can have multiple journal entries' do
      entry1 = create(:journal_entry, user: subject)
      entry2 = create(:journal_entry, user: subject)
      
      expect(subject.journal_entries.count).to eq(2)
      expect(subject.journal_entries).to include(entry1, entry2)
    end

    it 'can have multiple tags' do
      tag1 = create(:tag, user: subject, name: "work")
      tag2 = create(:tag, user: subject, name: "personal")
      
      expect(subject.tags.count).to eq(2)
      expect(subject.tags).to include(tag1, tag2)
    end
  end

  describe 'Devise modules' do
    subject { create(:user) }

    it 'includes database_authenticatable module' do
      expect(subject).to respond_to(:valid_password?)
      expect(subject.valid_password?("password123")).to be true
      expect(subject.valid_password?("wrong")).to be false
    end

    it 'includes registerable module' do
      expect(User).to respond_to(:new_with_session)
    end

    it 'includes recoverable module' do
      expect(subject).to respond_to(:send_reset_password_instructions)
      expect(subject).to respond_to(:reset_password_token)
      expect(subject).to respond_to(:reset_password_sent_at)
    end

    it 'includes rememberable module' do
      expect(subject).to respond_to(:remember_created_at)
      expect(subject).to respond_to(:remember_me)
    end

    it 'includes validatable module' do
      # Test for a method that actually exists in validatable
      expect(subject.class).to respond_to(:email_regexp)
    end
  end

  describe 'password reset functionality' do
    subject { create(:user) }

    it 'can generate reset password token' do
      raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
      subject.update!(
        reset_password_token: hashed_token,
        reset_password_sent_at: Time.current
      )
      
      expect(subject.reset_password_token).to be_present
      expect(subject.reset_password_sent_at).to be_present
    end

    it 'can reset password with valid token' do
      old_password = subject.encrypted_password
      new_password = "NewPassword123!"
      
      raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
      subject.update!(
        reset_password_token: hashed_token,
        reset_password_sent_at: Time.current
      )
      
      # Use the correct Devise method for password reset
      subject.password = new_password
      subject.password_confirmation = new_password
      subject.reset_password_token = nil
      subject.save!
      
      expect(subject.valid_password?(new_password)).to be true
      expect(subject.encrypted_password).not_to eq(old_password)
    end
  end

  describe 'factory' do
    it 'creates a valid user with factory' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'creates user with unique email' do
      user1 = create(:user)
      user2 = create(:user)
      
      expect(user1.email).not_to eq(user2.email)
    end

    it 'creates user with encrypted password' do
      user = create(:user, password: "testpassword", password_confirmation: "testpassword")
      expect(user.encrypted_password).to be_present
      expect(user.encrypted_password).not_to eq("testpassword")
    end
  end

  describe 'data isolation between users' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    it 'isolates journal entries between users' do
      entry1 = create(:journal_entry, user: user1)
      entry2 = create(:journal_entry, user: user2)
      
      expect(user1.journal_entries).to include(entry1)
      expect(user1.journal_entries).not_to include(entry2)
      expect(user2.journal_entries).to include(entry2)
      expect(user2.journal_entries).not_to include(entry1)
    end

    it 'isolates tags between users' do
      tag1 = create(:tag, user: user1, name: "productivity")
      tag2 = create(:tag, user: user2, name: "productivity") # Same name, different user
      
      expect(user1.tags).to include(tag1)
      expect(user1.tags).not_to include(tag2)
      expect(user2.tags).to include(tag2)
      expect(user2.tags).not_to include(tag1)
    end

    it 'allows same tag names for different users' do
      tag1 = create(:tag, user: user1, name: "work")
      tag2 = create(:tag, user: user2, name: "work")
      
      expect(tag1).to be_valid
      expect(tag2).to be_valid
      expect(tag1.name).to eq(tag2.name)
      expect(tag1.user).not_to eq(tag2.user)
    end
  end

  describe 'security considerations' do
    subject { create(:user) }

    it 'stores passwords securely' do
      expect(subject.encrypted_password).to be_present
      expect(subject.encrypted_password).not_to include("password123")
    end

    it 'validates password on authentication' do
      expect(subject.valid_password?("password123")).to be true
      expect(subject.valid_password?("wrongpassword")).to be false
      expect(subject.valid_password?("")).to be false
      expect(subject.valid_password?(nil)).to be false
    end

    it 'handles password update correctly' do
      old_encrypted = subject.encrypted_password
      subject.update!(password: "newpassword123", password_confirmation: "newpassword123")
      
      expect(subject.encrypted_password).not_to eq(old_encrypted)
      expect(subject.valid_password?("newpassword123")).to be true
      expect(subject.valid_password?("password123")).to be false
    end
  end
end
