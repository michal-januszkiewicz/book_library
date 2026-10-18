FactoryBot.define do
  factory :reader do
    sequence(:library_card_number) { |n| format("%06d", n) }
    name { Faker::Name.name }
    sequence(:email) { |n| "#{Faker::Internet.email}" }
  end
end
