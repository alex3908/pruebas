# frozen_string_literal: true

class SendSlackNotificationJob < ApplicationJob
  queue_as :high_priority

  def perform(message, hook)
    HTTParty.post(
      hook,
      body: {
        message: message
      }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
  rescue StandardError => e
    raise e
  end
end
