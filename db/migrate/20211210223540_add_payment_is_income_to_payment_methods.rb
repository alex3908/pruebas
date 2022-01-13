# frozen_string_literal: true

class AddPaymentIsIncomeToPaymentMethods < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_methods, :payment_is_income, :boolean, default: false
  end
end
