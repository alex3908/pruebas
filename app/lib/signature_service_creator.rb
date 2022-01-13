# frozen_string_literal: true

class SignatureServiceCreator
  def create_payment_service
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def create(properties, environment)
    create_payment_service(properties, environment)
  end
end
