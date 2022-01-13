# frozen_string_literal: true

module SuppressionEmailConcern
  extend ActiveSupport::Concern


  def suppresed_email?
    if is_postmark_enabled?
      is_suppresed_postmark?
    elsif is_mailgun_enabled?
      is_suppresed_mailgun?
    else
      false
    end
  end

  def delete_suppression
    if is_postmark_enabled?
      delete_suppression_postmark
    elsif is_mailgun_enabled?
      delete_suppression_mailgun
    else
      raise StandardError.new("Not implemented")
    end
  end

  private
    def is_postmark_enabled?
      ENV["POSTMARK_API_KEY"].present?
    end

    def is_mailgun_enabled?
      ENV["MAILGUN_API_KEY"].present? && ENV["MAILGUN_DOMAIN"].present? && !is_postmark_enabled?
    end

    def is_suppresed_mailgun?
      mailgun_client.get("#{ENV["MAILGUN_DOMAIN"]}/bounces/#{email}")
      true
    rescue Mailgun::CommunicationError
      false
    end

    def is_suppresed_postmark?
      postmark_client.dump_suppressions("outbound").find { |supression| supression.dig(:email_address) == email }.present?
    end

    def delete_suppression_mailgun
      return if !is_suppresed_mailgun?
      begin
        mailgun_client.delete("#{ENV["MAILGUN_DOMAIN"]}/bounces/#{email}")
        true
      rescue Mailgun::CommunicationError
        false
      end
    end

    def delete_suppression_postmark
      return if !is_suppresed_postmark?
      postmark_client.delete_suppressions("outbound", [email])
    end

    def postmark_client
      @postmark_client ||= begin
        Postmark::ApiClient.new(ENV["POSTMARK_API_KEY"])
      end
    end

    def mailgun_client
      @mailgun_client ||= begin
        Mailgun::Client.new(ENV["MAILGUN_API_KEY"])
      end
    end
end
