# frozen_string_literal: true

class RenamePromotionColumnInPaymentSchemes < ActiveRecord::Migration[5.2]
  def change
    rename_column :payment_schemes, :promotion, :promotion_discount
  end
end
