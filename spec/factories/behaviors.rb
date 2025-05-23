FactoryBot.define do
  factory :behavior do
    association :user
    name { Faker::Lorem.unique.words(number: 2).join(' ') }
  end
end
