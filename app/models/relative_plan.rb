# frozen_string_literal: true

class RelativePlan
  attr_accessor :total_payments, :discount

  def initialize(h)
    h.each { |k, v| public_send("#{k}=", v) }
  end
end
