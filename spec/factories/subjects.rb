FactoryBot.define do
  factory :subject do
    user
    name { Faker::Name.name }
    date_of_birth { Faker::Date.birthday(min_age: 2, max_age: 18) }
    notes { Faker::Lorem.paragraph }

    trait :minor do
      date_of_birth { 10.years.ago }
    end

    trait :with_future_date do
      date_of_birth { 1.day.from_now }
    end

    trait :without_date_of_birth do
      date_of_birth { nil }
    end
  end
end
