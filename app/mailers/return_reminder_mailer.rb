class ReturnReminderMailer < ApplicationMailer
  default from: "library@example.com"

  def before_due(borrowing)
    set_borrowing(borrowing)
    mail(to: @reader.email, subject: "The due date is approaching: please return #{@book.title}")
  end

  def on_due(borrowing)
    set_borrowing(borrowing)
    mail(to: @reader.email, subject: "Due today: please return #{@book.title}")
  end

  private

  def set_borrowing(borrowing)
    @book = borrowing.book
    @reader = borrowing.reader
    @due_on = borrowing.due_at.in_time_zone.to_date.to_s
  end
end
