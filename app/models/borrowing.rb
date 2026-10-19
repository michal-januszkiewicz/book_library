class Borrowing < ApplicationRecord
  BORROWING_PERIOD = 30.days
  BEFORE_DUE_REMINDER_DAYS = 3

  belongs_to :book
  belongs_to :reader

  scope :open, -> { where(returned_at: nil) }

  scope :needs_reminder_before_due_date, -> {
    today = Time.zone.today
    last_day = today + BEFORE_DUE_REMINDER_DAYS

    open
      .where(reminder_before_due_sent_at: nil)
      .where(due_at: (today + 1).beginning_of_day..last_day.end_of_day)
  }

  scope :needs_reminder_on_due_date, -> {
    today = Time.zone.today.to_date

    open
      .where(reminder_on_due_sent_at: nil)
      .where(due_at: ..today.end_of_day)
  }

  validates :borrowed_at, presence: true
  validates :due_at, presence: true
  validate :single_open_borrowing_per_book
  validate :returned_at_on_or_after_borrowed_at

  before_validation :assign_due_at, on: :create

  def open?
    returned_at.nil?
  end

  private

  def assign_due_at
    return if due_at.present?

    self.due_at = borrowed_at + BORROWING_PERIOD
  end

  def single_open_borrowing_per_book
    return if returned_at.present?
    return unless book.borrowings.open.where.not(id: id).exists?

    errors.add(:book, "is already borrowed")
  end

  def returned_at_on_or_after_borrowed_at
    return if returned_at.blank?
    return if returned_at >= borrowed_at

    errors.add(:returned_at, "must be on or after the borrow date")
  end
end
