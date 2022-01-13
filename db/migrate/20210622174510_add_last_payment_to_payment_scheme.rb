# frozen_string_literal: true

class AddLastPaymentToPaymentScheme < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_schemes, :with_last_payment, :boolean, default: false
    add_column :payment_schemes, :last_payment_amount, :decimal, default: 0
  end
end
