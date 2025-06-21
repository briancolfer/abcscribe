FactoryBot.define do
  factory :tag do
    name { Faker::Lorem.word.downcase }
    user
    
    trait :with_journal_entries do
      after(:create) do |tag|
        create_list(:journal_entry, 2, tags: [tag], user: tag.user)
      end
    end
    
    trait :work do
      name { ['work', 'productivity', 'meeting', 'deadline'].sample }
    end
    
    trait :personal do
      name { ['personal', 'health', 'exercise', 'family'].sample }
    end
  end
end
