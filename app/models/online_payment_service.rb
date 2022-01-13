# frozen_string_literal: true

class OnlinePaymentService < ApplicationRecord
  acts_as_paranoid

  scope :available, -> { all.filter { |s| s.validate_with_creator } }
  enum provider: HashWithIndifferentAccess.new(paypal: "PayPal", netpay: "Netpay", stp: "STP", webpay: "WebPay")
  store_accessor :properties, :keys, :charge, :loop

  belongs_to :enterprise
  belongs_to :payment_method, required: false, with_deleted: true
  belongs_to :bank_account, required: false
  belongs_to :branch, required: false

  def webhook
    default_url_options = Rails.application.config.action_mailer.default_url_options
    url = Rails.application.routes.url_helpers.webhook_subscriptions_url(default_url_options)

    api_result = webhook_manager.create_webhook(url)

    unless api_result.status == :success
      errors.add(:webhook, "#{api_result.status.to_s.capitalize}: #{api_result.error_message}")
    end
  end

  def properties_struct
    OpenStruct.new(properties)
  end


  def creator
    if provider == "netpay"
      NetpayBaseService.new(properties, environment)
    elsif provider == "paypal"
      PaypalBaseService.new(properties, environment)
    elsif provider == "stp"
      StpBaseService.new(properties, environment)
    elsif provider == "webpay"
      WebpayBaseService.new(properties, environment)
    end
  end

  def image
    if provider == "netpay"
      "netpay.png"
    elsif provider == "paypal"
      "paypal-full.png"
    elsif provider == "stp"
      "stp.png"
    elsif provider == "webpay"
      "webpay.png"
    end
  end

  def validate_with_creator
    creator.valid_service(properties)
  end

  def test?
    environment == "test"
  end

  def pay(description, token, amount, client, redirect_url, sku, address, test)
    payer = Payer.new(description, token, amount, client, redirect_url, sku, address, test, provider, properties, environment)
    response = payer.compute_payment
    raise StandardError, "Este servicio no disponible" if response == "no_availabe"
    response
  end

  def confirm(token, query_params = {})
    confirmer = Confirmer.new(token, query_params, provider, properties, environment)
    response = confirmer.compute_confirmation
    raise StandardError, "Este servicio no disponible" if response == "no_availabe"
    response
  end

  def suscribe(token, amount, concept, expiry_count, start_date, identifier, client)
    suscription_processor = NetpaySubscriptionProcessor.new(token, amount, concept, expiry_count, start_date, identifier, client, properties, environment)
    suscription_processor.suscribe
  end

  def webhook_manager
    NetpayWebhookManager.new(properties, environment)
  end

  def plan_manager
    NetpayPlanManager.new(properties, environment)
  end

  def suscription_manager
    NetpaySubscriptionManager.new(properties, environment)
  end

  def token_manager
    NetpayTokenManager.new(properties, environment)
  end

  def stp_service
    StpService.new(properties, environment)
  end

  def client_service
    NetpayClientService.new(properties, environment)
  end
end
