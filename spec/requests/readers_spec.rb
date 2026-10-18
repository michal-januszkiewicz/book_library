require "rails_helper"

RSpec.describe "Readers", type: :request do
  describe "GET /readers" do
    it "returns readers ordered by name" do
      create(:reader, name: "Michael Scott", library_card_number: "000002", email: "michael@example.com")
      create(:reader, name: "Jim Halpert", library_card_number: "000001", email: "jim@example.com")

      get "/readers"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.pluck("name")).to match_array([ "Jim Halpert", "Michael Scott" ])
    end
  end

  describe "POST /readers" do
    it "creates a reader" do
      post "/readers", params: {
        reader: {
          library_card_number: "123456",
          name: "Michael Scott",
          email: "michael@example.com"
        }
      }, as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to eq(
        "library_card_number" => "123456",
        "name" => "Michael Scott",
        "email" => "michael@example.com"
      )
    end

    it "returns errors when the reader is invalid" do
      post "/readers", params: { reader: { name: "" } }, as: :json

      expect(response).to have_http_status(422)
      expect(response.parsed_body["errors"]).to be_present
    end
  end
end
