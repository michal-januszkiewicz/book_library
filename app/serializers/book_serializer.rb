class BookSerializer
  class << self
    def one(book)
      summary(book).merge(borrowings: borrowings_for(book))
    end

    def collection(books)
      books.map { |book| summary(book) }
    end

    private

    def summary(book)
      {
        serial_number: book.serial_number,
        title: book.title,
        author: book.author,
        status: book.status
      }
    end

    def borrowings_for(book)
      book.borrowings.includes(:reader).order(:borrowed_at).map { |borrowing| borrowing_json(borrowing) }
    end

    def borrowing_json(borrowing)
      {
        borrowed_at: borrowing.borrowed_at,
        due_at: borrowing.due_at,
        returned_at: borrowing.returned_at,
        reader: ReaderSerializer.one(borrowing.reader)
      }
    end
  end
end
