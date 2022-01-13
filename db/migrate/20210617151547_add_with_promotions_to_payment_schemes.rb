# frozen_string_literal: true

class AddWithPromotionsToPaymentSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_schemes, :with_promotions, :boolean, default: true
  end
end
