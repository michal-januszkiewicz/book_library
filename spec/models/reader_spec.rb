require "rails_helper"

RSpec.describe Reader, type: :model do
  describe "library_card_number" do
    subject(:reader) { described_class.new(name: "Pam Beesly", email: "pam@example.com", library_card_number:) }

    context "when blank" do
      let(:library_card_number) { "" }

      it "reports that it can't be blank" do
        reader.validate

        expect(reader.errors[:library_card_number]).to eq([ "can't be blank" ])
      end
    end

    context "when the length is not 6" do
      let(:library_card_number) { "1234567" }

      it "reports that it must be 6 digits" do
        reader.validate

        expect(reader.errors[:library_card_number]).to eq([ "must be 6 digits" ])
      end
    end
  end
end
