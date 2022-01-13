# frozen_string_literal: true

class AddReferredClientConfigToCreditScheme < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_schemes, :reffered_client_payment_way, :string, default: "amount"
    add_column :credit_schemes, :reffered_client_amount, :decimal, default: 0
    add_reference :credit_schemes, :payment_method, index: true, foreign_key: true
  end
end
