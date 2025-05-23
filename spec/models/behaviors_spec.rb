require 'rails_helper'

RSpec.describe Behavior, type: :model do
  let(:user) { create(:user) }
  subject { build(:behavior, user: user) }

  it { should belong_to(:user) }
  it { should have_many(:journal_entries).dependent(:nullify) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:user_id) }
end
