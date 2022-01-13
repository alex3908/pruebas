# frozen_string_literal: true

class AddOpeningCommissionToPaymentScheme < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_schemes, :opening_commission, :decimal, default: 0
  end
end
