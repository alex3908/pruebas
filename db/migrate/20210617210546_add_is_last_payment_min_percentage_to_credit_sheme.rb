# frozen_string_literal: true

class AddIsLastPaymentMinPercentageToCreditSheme < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_schemes, :has_last_payment, :boolean, default: false
    add_column :credit_schemes, :min_last_payment_payment_way, :string, default: "percentage"
    add_column :credit_schemes, :min_last_payment_amount, :decimal, default: 0
  end
end
