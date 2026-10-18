require "rails_helper"

RSpec.describe Borrowing, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to("2026-10-28 08:00") { example.run }
  end

  describe ".needs_reminder_before_due_date" do
    subject(:reminders) { described_class.needs_reminder_before_due_date }

    context "when due after today within 3 days" do
      let!(:due_in_three_days) { create(:borrowing, due_at: "2026-10-31 15:00") }
      let!(:due_tomorrow) { create(:borrowing, due_at: "2026-10-29 09:00") }

      it "includes the borrowings" do
        expect(reminders).to contain_exactly(due_in_three_days, due_tomorrow)
      end
    end

    context "when reminded, returned, or out of range" do
      let!(:due_today) { create(:borrowing, due_at: "2026-10-28 18:00") }
      let!(:due_later) { create(:borrowing, due_at: "2026-11-01 08:00") }
      let!(:already_reminded) do
        create(:borrowing, due_at: "2026-10-30 15:00", reminder_before_due_sent_at: Time.current)
      end
      let!(:returned) do
        create(
          :borrowing,
          borrowed_at: "2026-10-01 08:00",
          due_at: "2026-10-30 15:00",
          returned_at: "2026-10-20 08:00"
        )
      end

      it "excludes the borrowings" do
        expect(reminders).to be_empty
      end
    end
  end

  describe ".needs_reminder_on_due_date" do
    subject(:reminders) { described_class.needs_reminder_on_due_date }

    context "when due today or overdue" do
      let!(:due_today) { create(:borrowing, due_at: "2026-10-28 18:00") }
      let!(:overdue) do
        create(
          :borrowing,
          borrowed_at: "2026-09-01 08:00",
          due_at: "2026-10-27 08:00"
        )
      end

      it "includes the borrowings" do
        expect(reminders).to contain_exactly(due_today, overdue)
      end
    end

    context "when due tomorrow, reminded, or returned" do
      let!(:due_tomorrow) { create(:borrowing, due_at: "2026-10-29 08:00") }
      let!(:already_reminded) do
        create(:borrowing, due_at: "2026-10-28 08:00", reminder_on_due_sent_at: Time.current)
      end
      let!(:returned) do
        create(
          :borrowing,
          borrowed_at: "2026-09-01 08:00",
          due_at: "2026-10-28 08:00",
          returned_at: "2026-10-20 08:00"
        )
      end

      it "excludes the borrowings" do
        expect(reminders).to be_empty
      end
    end
  end
end
