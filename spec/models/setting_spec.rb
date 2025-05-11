require 'rails_helper'

RSpec.describe Setting, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:observations).dependent(:nullify) }
    it { should have_many(:subjects).through(:observations) }
  end

  describe 'validations' do
    let(:user) { create(:user) }

    it { should validate_presence_of(:name) }

    it 'validates uniqueness of name scoped to user_id' do
      create(:setting, name: 'Classroom', user: user)
      duplicate_setting = build(:setting, name: 'Classroom', user: user)
      expect(duplicate_setting).not_to be_valid
    end

    it 'allows same name for different users' do
      setting1 = create(:setting, name: 'Classroom')
      setting2 = build(:setting, name: 'Classroom')
      expect(setting2).to be_valid
    end

    it "is valid with valid attributes" do
      setting = build(:setting)
      expect(setting).to be_valid
    end
    
    it "is not valid without a name" do
      setting = build(:setting, name: nil)
      expect(setting).not_to be_valid
      expect(setting.errors[:name]).to include("can't be blank")
    end
    
    it "is valid without a description" do
      setting = build(:setting, description: nil)
      expect(setting).to be_valid
    end
  end
end
