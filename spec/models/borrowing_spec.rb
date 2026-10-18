require "rails_helper"

RSpec.describe Borrowing, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to("2026-10-28 08:00") { example.run }
  end

  describe ".needs_reminder_before_due_date" do
    it "includes open borrowings due after today and within 3 days" do
      due_in_three_days = create(:borrowing, due_at: "2026-10-31 15:00")
      due_tomorrow = create(:borrowing, due_at: "2026-10-29 09:00")

      expect(described_class.needs_reminder_before_due_date).to contain_exactly(due_in_three_days, due_tomorrow)
    end

    it "excludes borrowings due today, due in more than 3 days, already reminded, or returned" do
      create(:borrowing, due_at: "2026-10-28 18:00")
      create(:borrowing, due_at: "2026-11-01 08:00")
      create(:borrowing, due_at: "2026-10-30 15:00", reminder_before_due_sent_at: Time.current)
      create(
        :borrowing,
        borrowed_at: "2026-10-01 08:00",
        due_at: "2026-10-30 15:00",
        returned_at: "2026-10-20 08:00"
      )

      expect(described_class.needs_reminder_before_due_date).to be_empty
    end
  end

  describe ".needs_reminder_on_due_date" do
    it "includes open borrowings due today or overdue" do
      due_today = create(:borrowing, due_at: "2026-10-28 18:00")
      overdue = create(
        :borrowing,
        borrowed_at: "2026-09-01 08:00",
        due_at: "2026-10-27 08:00"
      )

      expect(described_class.needs_reminder_on_due_date).to contain_exactly(due_today, overdue)
    end

    it "excludes borrowings due tomorrow, already reminded, or returned" do
      create(:borrowing, due_at: "2026-10-29 08:00")
      create(:borrowing, due_at: "2026-10-28 08:00", reminder_on_due_sent_at: Time.current)
      create(
        :borrowing,
        borrowed_at: "2026-09-01 08:00",
        due_at: "2026-10-28 08:00",
        returned_at: "2026-10-20 08:00"
      )

      expect(described_class.needs_reminder_on_due_date).to be_empty
    end
  end
end
