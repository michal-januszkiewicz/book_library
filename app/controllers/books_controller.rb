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
      if @book.borrow_book(params[:library_card_number])
        render json: BookSerializer.one(@book.reload)
      else
        render_errors(@book.errors)
      end
    when "available"
      if @book.return_book
        render json: BookSerializer.one(@book.reload)
      else
        render_errors(@book.errors)
      end
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
end
