require "rails_helper"

RSpec.describe Book, type: :model do
  describe "serial_number" do
    subject(:book) { described_class.new(title: "Dune", author: "Frank Herbert", serial_number:) }

    context "when blank" do
      let(:serial_number) { "" }

      it "reports that it can't be blank" do
        book.validate

        expect(book.errors[:serial_number]).to eq([ "can't be blank" ])
      end
    end

    context "when the length is not 6" do
      let(:serial_number) { "12345" }

      it "reports that it must be 6 digits" do
        book.validate

        expect(book.errors[:serial_number]).to eq([ "must be 6 digits" ])
      end
    end

    context "when it contains a non-digit" do
      let(:serial_number) { "12345a" }

      it "reports that it must be 6 digits" do
        book.validate

        expect(book.errors[:serial_number]).to eq([ "must be 6 digits" ])
      end
    end
  end
end
