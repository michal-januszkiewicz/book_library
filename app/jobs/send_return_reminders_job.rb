class SendReturnRemindersJob < ApplicationJob
  def perform
    send_before_due_reminders(Borrowing.needs_reminder_before_due_date)
    send_on_due_reminders(Borrowing.needs_reminder_on_due_date)
  end

  private

  def send_before_due_reminders(borrowings)
    borrowings
      .where(returned_at: nil)
      .where(reminder_before_due_sent_at: nil)
      .find_each do |borrowing|
        ReturnReminderMailer.before_due(borrowing).deliver_now
        borrowing.update!(reminder_before_due_sent_at: Time.current)
      end
  end

  def send_on_due_reminders(borrowings)
    borrowings
      .where(returned_at: nil)
      .where(reminder_on_due_sent_at: nil)
      .find_each do |borrowing|
        ReturnReminderMailer.on_due(borrowing).deliver_now
        borrowing.update!(reminder_on_due_sent_at: Time.current)
      end
  end
end
