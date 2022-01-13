# frozen_string_literal: true

class AddColumnsToPaymentMethods < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_methods, :active, :boolean, default: true
    add_column :payment_methods, :add_balance, :boolean, default: true
  end
end
