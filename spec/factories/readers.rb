FactoryBot.define do
  factory :reader do
    sequence(:library_card_number) { |n| format("%06d", n) }
    name { "Ada Lovelace" }
    sequence(:email) { |n| "reader#{n}@library.test" }
  end
end
