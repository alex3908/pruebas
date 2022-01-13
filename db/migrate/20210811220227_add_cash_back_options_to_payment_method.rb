# frozen_string_literal: true

class AddCashBackOptionsToPaymentMethod < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_methods, :reffered_client_cash_back, :boolean, default: false
    add_column :payment_methods, :reffered_client_cash_back_multiple, :boolean, default: false
  end
end
