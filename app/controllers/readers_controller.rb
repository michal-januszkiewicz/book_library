class ReadersController < ApplicationController
  def index
    readers = Reader.order(:name)

    render json: ReaderSerializer.collection(readers)
  end

  def create
    reader = Reader.new(reader_params)

    if reader.save
      render json: ReaderSerializer.one(reader), status: :created
    else
      render_errors(reader.errors)
    end
  end

  private

  def reader_params
    params.expect(reader: %i[library_card_number name email])
  end
end
