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
end
