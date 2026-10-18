require "rails_helper"

RSpec.describe SendReturnRemindersJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to("2026-10-28 08:00") { example.run }
  end

  before { ActionMailer::Base.deliveries.clear }

  it "sends the before-due reminder once" do
    borrowing = create(:borrowing, due_at: "2026-10-31 08:00")

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

  it "sends the due-date reminder once for a borrowing due today" do
    borrowing = create(:borrowing, due_at: "2026-10-28 18:00")

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

  it "sends a missed before-due reminder while the due date is still ahead" do
    borrowing = create(:borrowing, due_at: "2026-10-29 08:00")

    described_class.perform_now

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(borrowing.reload.reminder_before_due_sent_at).to be_present
    expect(borrowing.reminder_on_due_sent_at).to be_nil
  end

  it "skips returned borrowings and borrowings due in more than 3 days" do
    create(:borrowing, due_at: "2026-11-01 08:00")
    create(
      :borrowing,
      borrowed_at: "2026-10-01 08:00",
      due_at: "2026-10-28 08:00",
      returned_at: "2026-10-10 08:00"
    )

    described_class.perform_now

    expect(ActionMailer::Base.deliveries).to be_empty
  end
end
