# frozen_string_literal: true

class AddCashBackToPaymentMethods < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_methods, :cash_back, :boolean, default: false
  end
end
