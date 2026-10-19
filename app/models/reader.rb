class Reader < ApplicationRecord
  has_many :borrowings, dependent: :restrict_with_error
  has_many :books, through: :borrowings

  validates :library_card_number,
            presence: true,
            uniqueness: true,
            format: { with: /\A\d{6}\z/, allow_blank: true, message: "must be 6 digits" }
  validates :name, presence: true, length: { maximum: 255 }
  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            length: { maximum: 255 }

  normalizes :email, with: ->(email) { email.strip.downcase }
end
