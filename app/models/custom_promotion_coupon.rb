# frozen_string_literal: true

class CustomPromotionCoupon
  attr_accessor :promotion, :promotion_operation, :promotion_discount_type, :coupon, :coupon_operation

  def initialize(h)
    h.each { |k, v| public_send("#{k}=", v) }
  end
end
