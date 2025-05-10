FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    
    # User with short password (for validation testing)
    trait :with_short_password do
      password { "short" }
      password_confirmation { "short" }
    end
    
    # User with invalid email
    trait :with_invalid_email do
      email { "invalid_email" }
    end
    
    # User with a remember token
    trait :remembered do
      after(:create) do |user|
        user.remember
      end
    end
  end
end
