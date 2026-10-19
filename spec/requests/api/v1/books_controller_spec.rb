require "rails_helper"

RSpec.describe Api::V1::BooksController, type: :request do
  describe "GET /api/v1/books" do
    let!(:hyperion) { create(:book, title: "Hyperion", author: "Dan Simmons", serial_number: "000001") }
    let!(:dune) { create(:book, title: "Dune", author: "Frank Herbert", serial_number: "000002") }

    it "returns books ordered by title" do
      get "/api/v1/books"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.pluck("title")).to eq([ dune.title, hyperion.title ])
    end

    it "returns the requested page" do
      get "/api/v1/books", params: { page: 2, per_page: 1 }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.pluck("title")).to eq([ hyperion.title ])
    end
  end

  describe "GET /api/v1/books/:serial_number" do
    subject(:send_request) { get "/api/v1/books/#{book.serial_number}" }

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

  describe "POST /api/v1/books" do
    subject(:send_request) { post "/api/v1/books", params: { book: book_params }, as: :json }

    context "with valid params" do
      let(:book_params) { { serial_number: "123456", title: "Dune", author: "Frank Herbert" } }

      it "creates a book" do
        send_request

        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to include(
          "serial_number" => "123456",
          "title" => "Dune",
          "author" => "Frank Herbert",
          "status" => "available"
        )
      end
    end

    context "when not valid" do
      let(:book_params) { { title: "" } }

      it "returns errors" do
        send_request

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["errors"]).to be_present
      end
    end
  end

  describe "POST /api/v1/books/:serial_number/borrow" do
    subject(:send_request) { post "/api/v1/books/#{book.serial_number}/borrow", params:, as: :json }

    let(:book) { create(:book, serial_number: "123456") }
    let(:reader) { create(:reader, library_card_number: "654321") }
    let(:params) { { library_card_number: reader.library_card_number } }

    it "borrows a book" do
      send_request

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["status"]).to eq("borrowed")
    end

    context "when the library card does not match a reader" do
      let(:params) { { library_card_number: "000000" } }

      it "returns an error" do
        send_request

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["errors"]).to eq(
          "library_card_number" => [ "does not match a reader" ]
        )
        expect(book.reload).to be_available
      end
    end
  end

  describe "POST /api/v1/books/:serial_number/return" do
    subject(:send_request) { post "/api/v1/books/#{book.serial_number}/return" }

    let(:book) { create(:book, serial_number: "123456") }
    let!(:borrowing) { create(:borrowing, book:) }

    it "returns a borrowed book" do
      send_request

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["status"]).to eq("available")
    end
  end

  describe "DELETE /api/v1/books/:serial_number" do
    let!(:book) { create(:book, serial_number: "123456") }

    it "deletes the book" do
      delete "/api/v1/books/#{book.serial_number}"

      expect(response).to have_http_status(:no_content)
      expect(Book.exists?(serial_number: book.serial_number)).to be(false)
    end
  end
end
