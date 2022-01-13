# frozen_string_literal: true

class AddDiscountAmountToPromotions < ActiveRecord::Migration[5.2]
  def change
    add_column :promotions, :discount_type, :integer
  end
end
