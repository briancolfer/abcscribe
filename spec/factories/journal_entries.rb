FactoryBot.define do
  factory :journal_entry do
    association :user
    occurred_at { Time.current }
    antecedent { "Started feeling overwhelmed" }
    behavior { "Took a 10-minute break" }
    consequence { "Felt productive!" }
    reinforcement_type { :positive }
  end
end
