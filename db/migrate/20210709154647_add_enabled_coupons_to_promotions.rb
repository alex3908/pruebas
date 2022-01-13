# frozen_string_literal: true

class AddEnabledCouponsToPromotions < ActiveRecord::Migration[5.2]
  def change
    add_column :promotions, :enabled_coupons, :boolean, default: false
  end
end
