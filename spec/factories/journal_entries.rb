FactoryBot.define do
  factory :journal_entry do
    antecedent { "Manager assigned new project with tight deadline" }
    behavior { "Organized tasks into priority list and set 25-minute work blocks" }
    consequence { "Completed first milestone ahead of schedule" }
    user
  end
end
