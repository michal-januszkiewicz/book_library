require "rails_helper"

RSpec.describe "Books", type: :request do
  describe "GET /books" do
    let!(:hyperion) { create(:book, title: "Hyperion", author: "Dan Simmons", serial_number: "000001") }
    let!(:dune) { create(:book, title: "Dune", author: "Frank Herbert", serial_number: "000002") }

    it "returns books ordered by title" do
      get "/books"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.pluck("title")).to match_array([ hyperion.title, dune.title ])
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
    subject(:send_request) { post "/books", params: { book: book_params }, as: :json }

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

  describe "PATCH /books/:serial_number" do
    subject(:send_request) { patch "/books/#{book.serial_number}", params:, as: :json }

    let(:book) { create(:book, serial_number: "123456") }

    context "when borrowing" do
      let(:reader) { create(:reader, library_card_number: "654321") }
      let(:params) { { status: "borrowed", library_card_number: reader.library_card_number } }

      it "borrows a book" do
        send_request

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["status"]).to eq("borrowed")
      end
    end

    context "when returning" do
      let!(:borrowing) { create(:borrowing, book:) }
      let(:params) { { status: "available" } }

      it "returns a borrowed book" do
        send_request

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["status"]).to eq("available")
      end
    end
  end

  describe "DELETE /books/:serial_number" do
    let!(:book) { create(:book, serial_number: "123456") }

    it "deletes the book" do
      delete "/books/#{book.serial_number}"

      expect(response).to have_http_status(:no_content)
      expect(Book.exists?(serial_number: book.serial_number)).to be(false)
    end
  end
end
