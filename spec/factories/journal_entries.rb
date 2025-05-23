FactoryBot.define do
  factory :journal_entry do
    association :user
    association :behavior
    occurred_at { Time.current }
    consequence { "Felt productive!" }
    reinforcement_type { :positive }
  end
end
