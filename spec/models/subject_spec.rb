require 'rails_helper'

RSpec.describe Subject, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:observations).dependent(:destroy) }
    it { should have_many(:settings).through(:observations) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }

    describe 'date_of_birth validation' do
      let(:user) { create(:user) }

      it 'allows valid date of birth' do
        subject = build(:subject, user: user)
        expect(subject).to be_valid
      end

      it 'allows nil date of birth' do
        subject = build(:subject, :without_date_of_birth, user: user)
        expect(subject).to be_valid
      end

      it 'does not allow future date of birth' do
        subject = build(:subject, :with_future_date, user: user)
        expect(subject).not_to be_valid
        expect(subject.errors[:date_of_birth]).to include("must be in the past")
      end
      
      it "is not valid without a name" do
        subject = build(:subject, name: nil)
        expect(subject).not_to be_valid
        expect(subject.errors[:name]).to include("can't be blank")
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:subject)).to be_valid
    end

    it 'has a valid minor factory' do
      expect(build(:subject, :minor)).to be_valid
    end
  end
end
