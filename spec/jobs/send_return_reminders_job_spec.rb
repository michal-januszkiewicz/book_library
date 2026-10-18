require "rails_helper"

RSpec.describe SendReturnRemindersJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to("2026-10-28 08:00") { example.run }
  end

  before { ActionMailer::Base.deliveries.clear }

  describe "#perform" do
    context "when due in 3 days" do
      let!(:borrowing) { create(:borrowing, due_at: "2026-10-31 08:00") }

      it "sends the before-due reminder once" do
        described_class.perform_now

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([ borrowing.reader.email ])
        expect(mail.subject).to eq("The due date is approaching: please return #{borrowing.book.title}")
        expect(mail.body.decoded).to include(borrowing.book.serial_number, borrowing.reader.name)
        expect(borrowing.reload.reminder_before_due_sent_at).to be_within(1.second).of(Time.current)
        expect(borrowing.reminder_on_due_sent_at).to be_nil

        described_class.perform_now

        expect(ActionMailer::Base.deliveries.size).to eq(1)
      end
    end

    context "when due today" do
      let!(:borrowing) { create(:borrowing, due_at: "2026-10-28 18:00") }

      it "sends the due-date reminder once" do
        described_class.perform_now

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([ borrowing.reader.email ])
        expect(mail.subject).to eq("Due today: please return #{borrowing.book.title}")
        expect(mail.body.decoded).to include(borrowing.book.serial_number, "today")
        expect(borrowing.reload.reminder_on_due_sent_at).to be_within(1.second).of(Time.current)
        expect(borrowing.reminder_before_due_sent_at).to be_nil

        described_class.perform_now

        expect(ActionMailer::Base.deliveries.size).to eq(1)
      end
    end

    context "when due tomorrow" do
      let!(:borrowing) { create(:borrowing, due_at: "2026-10-29 08:00") }

      it "sends a missed before-due reminder" do
        described_class.perform_now

        expect(ActionMailer::Base.deliveries.size).to eq(1)
        expect(borrowing.reload.reminder_before_due_sent_at).to be_present
        expect(borrowing.reminder_on_due_sent_at).to be_nil
      end
    end

    context "when returned or due in more than 3 days" do
      let!(:due_later) { create(:borrowing, due_at: "2026-11-01 08:00") }
      let!(:returned) do
        create(
          :borrowing,
          borrowed_at: "2026-10-01 08:00",
          due_at: "2026-10-28 08:00",
          returned_at: "2026-10-10 08:00"
        )
      end

      it "skips the borrowings" do
        described_class.perform_now

        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end
end
