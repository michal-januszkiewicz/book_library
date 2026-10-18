require "rails_helper"

RSpec.describe LogEmailDelivery, type: :mailer do
  it "logs the email payload" do
    mail = Mail.new(
      to: "reader@example.com",
      from: "library@example.com",
      subject: "Reminder",
      body: "Please return Dune"
    )

    expect(Rails.logger).to receive(:info) do |message|
      expect(JSON.parse(message)).to include(
        "to" => [ "reader@example.com" ],
        "from" => [ "library@example.com" ],
        "subject" => "Reminder",
        "body" => "Please return Dune"
      )
    end

    described_class.new({}).deliver!(mail)
  end
end
