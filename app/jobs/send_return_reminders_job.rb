class SendReturnRemindersJob < ApplicationJob
  def perform
    log("SendReturnRemindersJob started")

    before_due_count = send_before_due_reminders
    on_due_count = send_on_due_reminders

    log("SendReturnRemindersJob finished: #{before_due_count} before-due, #{on_due_count} on-due")
  end

  private

  def send_before_due_reminders
    borrowings = Borrowing
      .needs_reminder_before_due_date
      .where(returned_at: nil)
      .where(reminder_before_due_sent_at: nil)

    send_reminders(borrowings, :before_due, :reminder_before_due_sent_at)
  end

  def send_on_due_reminders
    borrowings = Borrowing
      .needs_reminder_on_due_date
      .where(returned_at: nil)
      .where(reminder_on_due_sent_at: nil)

    send_reminders(borrowings, :on_due, :reminder_on_due_sent_at)
  end

  def send_reminders(borrowings, mailer_method, sent_at_column)
    count = 0

    borrowings
      .includes(:reader, :book)
      .find_each do |borrowing|
        log("Sending #{mailer_method} reminder to #{borrowing.reader.email} about #{borrowing.book.title}")

        ReturnReminderMailer.public_send(mailer_method, borrowing).deliver_now
        borrowing.update!(sent_at_column => Time.current)

        log("Sent #{mailer_method} reminder to #{borrowing.reader.email} about #{borrowing.book.title}")
        count += 1
      end

    count
  end

  def log(message)
    logger.info(message)
    $stdout.puts(message) if Rails.env.development?
  end
end
