# frozen_string_literal: true

module PromotionHandler
  extend ActiveSupport::Concern

  def promotion_calculator(price, discount = 0, exclusive_promotion = 0, exclusive_promotion_type = nil, promotion = 0, promotion_type = nil, coupon = 0, coupon_type = nil, promotion_discount_type = nil)
    applied_inverse_discount = discount

    loop do
      if !promotion.zero?
        promotion = caculate_percentage(promotion, price) if promotion_discount_type = "amount"
        applied_inverse_discount = calculate_discount(promotion_type, applied_inverse_discount, promotion)
        promotion = 0
      elsif !coupon.zero?
        applied_inverse_discount = calculate_discount(coupon_type, applied_inverse_discount, coupon)
        coupon = 0
      elsif !exclusive_promotion.zero?
        calculate_discount(exclusive_promotion_type, applied_inverse_discount, exclusive_promotion)
        exclusive_promotion = 0
      end

      break if exclusive_promotion.zero? && promotion.zero? && coupon.zero?
    end

    Price.new(
      savings: price * applied_inverse_discount,
      total: price * (1 - applied_inverse_discount),
      discount: applied_inverse_discount * 100
    )
  end

  def calculate_discount(type, discount, promotion)
    if type == "over"
      applied_inverse_discount = (1 - discount) * (1 - promotion)
    elsif type == "higher"
      applied_inverse_discount = [(1 - discount), (1 - promotion)].min
    elsif type == "addition"
      applied_inverse_discount = (1 - (discount + promotion))
    else
      applied_inverse_discount = 1
    end
    1 - applied_inverse_discount
  end

  def caculate_percentage(promotion, price)
    ((promotion * 100).round / 100.0) / ((price * 100).round / 100.0) * 100
  end
end
