# frozen_string_literal: true

module WebhookManager
  def delete_webhook
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def create_webhook
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end
