require "rails_helper"

RSpec.describe "Books", type: :request do
  describe "GET /books" do
    it "returns books ordered by title" do
      create(:book, title: "Dune", author: "Frank Herbert", serial_number: "000002")
      create(:book, title: "Hyperion", author: "Dan Simmons", serial_number: "000001")

      get "/books"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.pluck("title")).to match_array([ "Hyperion", "Dune" ])
    end
  end

  describe "GET /books/:serial_number" do
    subject(:send_request) { get "/books/#{book.serial_number}" }

    let!(:book) { create(:book, serial_number: "123456", title: "Dune", author: "Frank Herbert") }

    context "when the book is available" do
      it "returns the book" do
        send_request

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include(
          "serial_number" => "123456",
          "title" => "Dune",
          "author" => "Frank Herbert",
          "status" => "available"
        )
      end
    end

    context "when the book is borrowed" do
      let!(:borrowing) { create(:borrowing, book:) }

      it "returns the book" do
        send_request

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include(
          "serial_number" => "123456",
          "title" => "Dune",
          "author" => "Frank Herbert",
          "status" => "borrowed",
          "borrowings" => [
            {
              "borrowed_at" => borrowing.borrowed_at.as_json,
              "due_at" => borrowing.due_at.as_json,
              "returned_at" => borrowing.returned_at.as_json,
              "reader" => {
                "library_card_number" => borrowing.reader.library_card_number,
                "name" => borrowing.reader.name,
                "email" => borrowing.reader.email
              }
            }
          ]
        )
      end
    end
  end

  describe "POST /books" do
    it "creates a book" do
      post "/books", params: {
        book: { serial_number: "123456", title: "Dune", author: "Frank Herbert" }
      }, as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to include(
        "serial_number" => "123456",
        "title" => "Dune",
        "author" => "Frank Herbert",
        "status" => "available"
      )
    end

    it "returns errors when the book is invalid" do
      post "/books", params: { book: { title: "" } }, as: :json

      expect(response).to have_http_status(422)
      expect(response.parsed_body["errors"]).to be_present
    end
  end

  describe "PATCH /books/:serial_number" do
    it "borrows a book" do
      create(:book, serial_number: "123456")
      reader = create(:reader, library_card_number: "654321")

      patch "/books/123456", params: {
        status: "borrowed",
        library_card_number: reader.library_card_number
      }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["status"]).to eq("borrowed")
    end

    it "returns a borrowed book" do
      book = create(:book, serial_number: "123456")
      create(:borrowing, book:)

      patch "/books/123456", params: { status: "available" }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["status"]).to eq("available")
    end
  end

  describe "DELETE /books/:serial_number" do
    it "deletes the book" do
      create(:book, serial_number: "123456")

      delete "/books/123456"

      expect(response).to have_http_status(:no_content)
      expect(Book.exists?(serial_number: "123456")).to be(false)
    end
  end
end
