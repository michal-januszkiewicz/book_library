class BookSerializer
  class << self
    def one(book)
      book_json(book)
    end

    def one_with_history(book)
      book_json(book).merge(borrowings: borrowings_for(book))
    end

    def collection(books)
      books.map { |book| book_json(book) }
    end

    private

    def book_json(book)
      {
        serial_number: book.serial_number,
        title: book.title,
        author: book.author,
        status: book.status
      }
    end

    def borrowings_for(book)
      book.borrowings.sort_by(&:borrowed_at).map { |borrowing| borrowing_json(borrowing) }
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
