FactoryBot.define do
  factory :book do
    sequence(:serial_number) { |n| format("%06d", n) }
    title { Faker::Book.title }
    author { Faker::Book.author }
  end
end
