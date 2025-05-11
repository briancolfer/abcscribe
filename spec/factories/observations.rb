FactoryBot.define do
  factory :observation do
    user
    subject
    setting
    observed_at { Time.current - 1.hour }
    antecedent { "Student was given a math worksheet" }
    behavior { "Completed the first three problems independently" }
    consequence { "Received praise for effort and focus" }
    notes { "Good engagement throughout the task" }

    trait :with_notes do
      notes { Faker::Lorem.paragraph(sentence_count: 2) }
    end

    trait :without_setting do
      setting { nil }
    end

    trait :recent do
      observed_at { Time.current - 30.minutes }
    end

    trait :old do
      observed_at { Time.current - 1.week }
    end

    trait :future do
      observed_at { Time.current + 1.hour }
    end

    trait :random_content do
      antecedent { Faker::Lorem.paragraph }
      behavior { Faker::Lorem.paragraph }
      consequence { Faker::Lorem.paragraph }
      notes { Faker::Lorem.paragraph }
    end
  end
end
