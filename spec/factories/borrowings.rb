FactoryBot.define do
  factory :borrowing do
    book
    reader
    borrowed_at { Time.current }

    trait :returned do
      borrowed_at { 10.days.ago }
      returned_at { 5.days.ago }
    end
  end
end
