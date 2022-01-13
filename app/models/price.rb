# frozen_string_literal: true

class Price
  attr_accessor :savings, :total, :discount

  def initialize(h)
    h.each { |k, v| public_send("#{k}=", v) }
  end
end
