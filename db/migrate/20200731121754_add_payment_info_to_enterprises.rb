# frozen_string_literal: true

class AddPaymentInfoToEnterprises < ActiveRecord::Migration[5.2]
  def change
    add_column :enterprises, :merchant_id, :string
    add_column :enterprises, :public_key, :string
    add_column :enterprises, :secret_key, :string
    add_column :enterprises, :email, :string
    add_column :enterprises, :encrypted_password, :string

    remove_column :enterprises, :transaction_merchant_id
    remove_column :enterprises, :transaction_public_key
    remove_column :enterprises, :transaction_private_key
  end
end
