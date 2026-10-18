Rails.application.config.to_prepare do
  ActionMailer::Base.add_delivery_method :logger, LogEmailDelivery, logger: Rails.logger
end
