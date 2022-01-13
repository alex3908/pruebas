# frozen_string_literal: true

module PaymentProcessor
  def pay
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end
