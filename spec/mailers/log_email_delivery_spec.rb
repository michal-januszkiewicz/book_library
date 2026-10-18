require "rails_helper"

RSpec.describe LogEmailDelivery, type: :mailer do
  describe "#deliver!" do
    subject(:deliver_mail) { described_class.new({}).deliver!(mail) }

    let(:mail) do
      Mail.new(
        to: "reader@example.com",
        from: "library@example.com",
        subject: "Reminder",
        body: "Please return Dune"
      )
    end

    it "logs the email payload" do
      expect(Rails.logger).to receive(:info) do |message|
        expect(JSON.parse(message)).to include(
          "to" => [ "reader@example.com" ],
          "from" => [ "library@example.com" ],
          "subject" => "Reminder",
          "body" => "Please return Dune"
        )
      end

      deliver_mail
    end
  end
end
