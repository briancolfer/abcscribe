FactoryBot.define do
  factory :setting do
    name { "#{Faker::House.room} at #{Faker::Company.name}" }
    description { Faker::Lorem.paragraph }
    user

    trait :with_observations do
      after(:create) do |setting|
        create_list(:observation, 3, setting: setting, user: setting.user)
      end
    end
  end
end
