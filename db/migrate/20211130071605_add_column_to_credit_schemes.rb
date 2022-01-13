# frozen_string_literal: true

class AddColumnToCreditSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_schemes, :cancellation_balance, :decimal, default: 0
    add_column :credit_schemes, :down_payment_balance, :integer
    add_column :credit_schemes, :principal_balance, :integer
    add_column :credit_schemes, :balance_of_updates, :integer
  end
end
