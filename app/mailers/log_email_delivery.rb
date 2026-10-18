class LogEmailDelivery
  def initialize(settings = {})
    @logger = settings.fetch(:logger) { Rails.logger }
  end

  def deliver!(mail)
    @logger.info(email_payload(mail).to_json)
  end

  private

  def email_payload(mail)
    {
      to: Array(mail.to),
      from: Array(mail.from),
      subject: mail.subject,
      body: mail_body(mail)
    }
  end

  def mail_body(mail)
    part = mail.text_part || mail
    part.body.decoded
  end
end
