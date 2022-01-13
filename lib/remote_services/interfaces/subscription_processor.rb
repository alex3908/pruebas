# frozen_string_literal: true

module SubscriptionProcessor
  def suscribe
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end
