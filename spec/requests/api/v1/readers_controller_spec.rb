require "rails_helper"

RSpec.describe Api::V1::ReadersController, type: :request do
  describe "GET /api/v1/readers" do
    let!(:jim) { create(:reader, name: "Jim Halpert", library_card_number: "000001", email: "jim@example.com") }
    let!(:michael) { create(:reader, name: "Michael Scott", library_card_number: "000002", email: "michael@example.com") }

    it "returns readers ordered by name" do
      get "/api/v1/readers"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.pluck("name")).to match_array([ jim.name, michael.name ])
    end
  end

  describe "POST /api/v1/readers" do
    subject(:send_request) { post "/api/v1/readers", params: { reader: reader_params }, as: :json }

    context "with valid params" do
      let(:reader_params) do
        {
          library_card_number: "123456",
          name: "Michael Scott",
          email: "michael@example.com"
        }
      end

      it "creates a reader" do
        send_request

        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to eq(
          "library_card_number" => "123456",
          "name" => "Michael Scott",
          "email" => "michael@example.com"
        )
      end
    end

    context "when not valid" do
      let(:reader_params) { { name: "" } }

      it "returns errors" do
        send_request

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["errors"]).to be_present
      end
    end
  end
end
