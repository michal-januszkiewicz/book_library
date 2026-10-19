module Api
  module V1
    class BooksController < ApplicationController
      before_action :set_book, only: %i[show borrow_book return_book destroy]

      def index
        books = Book.includes(:current_borrowing).order(:title)

        render json: BookSerializer.collection(books)
      end

      def show
        book = Book.includes(borrowings: :reader).find(@book.id)
        render json: BookSerializer.one_with_history(book)
      end

      def create
        book = Book.new(book_params)

        if book.save
          render json: BookSerializer.one(book), status: :created
        else
          render_errors(book.errors)
        end
      end

      def borrow_book
        reader = find_reader
        return if reader.blank?

        if @book.borrow_book(reader)
          render json: BookSerializer.one(@book.reload)
        else
          render_errors(@book.errors)
        end
      end

      def return_book
        if @book.return_book
          render json: BookSerializer.one(@book.reload)
        else
          render_errors(@book.errors)
        end
      end

      def destroy
        if @book.destroy
          head :no_content
        else
          render_errors(@book.errors)
        end
      end

      private

      def find_reader
        library_card_number = params.expect(:library_card_number)
        reader = Reader.find_by(library_card_number:)
        return reader if reader

        render_errors({ library_card_number: [ "does not match a reader" ] })
        nil
      end

      def set_book
        @book = Book.find_by!(serial_number: params.expect(:serial_number))
      end

      def book_params
        params.expect(book: %i[serial_number title author])
      end
    end
  end
end
