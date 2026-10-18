class SendReturnRemindersJob < ApplicationJob
  def perform
    send_before_due_reminders(Borrowing.needs_reminder_before_due_date)
    send_on_due_reminders(Borrowing.needs_reminder_on_due_date)
  end

  private

  def send_before_due_reminders(borrowings)
    borrowings.find_each do |borrowing|
      next if borrowing.returned_at.present?
      next if borrowing.reminder_before_due_sent_at.present?

      ReturnReminderMailer.before_due(borrowing).deliver_now
      borrowing.update!(reminder_before_due_sent_at: Time.current)
    end
  end

  def send_on_due_reminders(borrowings)
    borrowings.find_each do |borrowing|
      next if borrowing.returned_at.present?
      next if borrowing.reminder_on_due_sent_at.present?

      ReturnReminderMailer.on_due(borrowing).deliver_now
      borrowing.update!(reminder_on_due_sent_at: Time.current)
    end
  end
end
