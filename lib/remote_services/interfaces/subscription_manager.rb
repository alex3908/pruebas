# frozen_string_literal: true

module SubscriptionManager
  def get_subscription
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def subscribe_variable
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def update_subscription_amount
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def update_subscription
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def cancel_subscription
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end
