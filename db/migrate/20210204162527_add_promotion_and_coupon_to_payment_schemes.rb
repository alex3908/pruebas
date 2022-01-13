# frozen_string_literal: true

class AddPromotionAndCouponToPaymentSchemes < ActiveRecord::Migration[5.2]
  def change
    add_reference :payment_schemes, :promotion, index: true, foreign_key: true
    add_reference :payment_schemes, :coupon, index: true, foreign_key: true
  end
end
