FactoryBot.define do
  factory :magic_link_token do
    user { nil }
    token { "MyString" }
    expires_at { "2025-06-04 22:16:52" }
  end
end
