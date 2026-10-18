class Borrowing < ApplicationRecord
  LOAN_PERIOD = 30.days

  belongs_to :book
  belongs_to :reader

  scope :open, -> { where(returned_at: nil) }

  validates :borrowed_at, presence: true
  validates :due_at, presence: true
  validate :single_open_loan_per_book
  validate :returned_at_on_or_after_borrowed_at

  before_validation :assign_due_at, on: :create

  def open?
    returned_at.nil?
  end

  private

  def assign_due_at
    return if due_at.present?

    self.due_at = borrowed_at + LOAN_PERIOD
  end

  def single_open_loan_per_book
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
