class BooksController < ApplicationController
  before_action :set_book, only: %i[show update destroy]

  def index
    books = Book.includes(:current_borrowing).order(:title)

    render json: BookSerializer.collection(books)
  end

  def show
    render json: BookSerializer.one(@book)
  end

  def create
    book = Book.new(book_params)

    if book.save
      render json: BookSerializer.one(book), status: :created
    else
      render_errors(book.errors)
    end
  end

  def update
    case params.require(:status)
    when "borrowed"
      borrow_book
    when "available"
      return_book
    else
      render_errors({ status: [ "must be borrowed or available" ] })
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

  def set_book
    @book = Book.find_by!(serial_number: params[:serial_number])
  end

  def book_params
    params.expect(book: %i[serial_number title author])
  end

  def borrow_book
    card_number = params[:library_card_number]
    if card_number.blank?
      render_errors({ library_card_number: [ "can't be blank" ] })
      return
    end

    reader = Reader.find_by(library_card_number: card_number)
    if reader.nil?
      render_errors({ library_card_number: [ "does not match a reader" ] })
      return
    end

    borrowing = @book.borrowings.build(reader:, borrowed_at: Time.current)

    if borrowing.save
      render json: BookSerializer.one(@book.reload)
    else
      render_errors(borrowing.errors)
    end
  rescue ActiveRecord::RecordNotUnique
    render_errors({ book: [ "is already borrowed" ] })
  end

  def return_book
    borrowing = @book.current_borrowing
    if borrowing.nil?
      render_errors({ status: [ "is already available" ] })
      return
    end

    if borrowing.update(returned_at: Time.current)
      render json: BookSerializer.one(@book.reload)
    else
      render_errors(borrowing.errors)
    end
  end
end
