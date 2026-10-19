# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

reader_1 = Reader.find_or_create_by!(library_card_number: "111111") do |reader|
  reader.name = "Jim Halpert"
  reader.email = "jim@example.com"
end

book_1 = Book.find_or_create_by!(serial_number: "222222") do |book|
  book.title = "The Lord of the Rings"
  book.author = "J. R. R. Tolkien"
end

Borrowing.find_or_create_by!(book: book_1, reader: reader_1) do |borrowing|
  borrowing.borrowed_at = 27.days.ago
end

reader_2 = Reader.find_or_create_by!(library_card_number: "333333") do |reader|
  reader.name = "Dwight Schrute"
  reader.email = "dwight@example.com"
end

book_2 = Book.find_or_create_by!(serial_number: "444444") do |book|
  book.title = "The Count of Monte Cristo"
  book.author = "Alexandre Dumas"
end

Borrowing.find_or_create_by!(book: book_2, reader: reader_2) do |borrowing|
  borrowing.borrowed_at = 30.days.ago
end
