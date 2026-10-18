class Book < ApplicationRecord
  has_many :borrowings, dependent: :restrict_with_error
  has_many :readers, through: :borrowings
  has_one :current_borrowing, -> { open }, class_name: "Borrowing", inverse_of: :book

  validates :serial_number,
            presence: true,
            uniqueness: true,
            format: { with: /\A\d{6}\z/ }
  validates :serial_number, length: { is: 6 }
  validates :title, presence: true, length: { maximum: 255 }
  validates :author, presence: true, length: { maximum: 255 }

  def borrowed?
    current_borrowing.present?
  end

  def available?
    !borrowed?
  end

  def status
    borrowed? ? "borrowed" : "available"
  end

  def borrow_book(library_card_number)
    errors.clear

    if library_card_number.blank?
      errors.add(:library_card_number, "can't be blank")
      return false
    end

    reader = Reader.find_by(library_card_number:)
    if reader.nil?
      errors.add(:library_card_number, "does not match a reader")
      return false
    end

    borrowing = borrowings.build(reader:, borrowed_at: Time.current)
    return true if borrowing.save

    errors.merge!(borrowing.errors)
    false
  rescue ActiveRecord::RecordNotUnique
    errors.add(:book, "is already borrowed")
    false
  end

  def return_book
    errors.clear

    borrowing = current_borrowing
    if borrowing.nil?
      errors.add(:status, "is already available")
      return false
    end

    return true if borrowing.update(returned_at: Time.current)

    errors.merge!(borrowing.errors)
    false
  end
end
