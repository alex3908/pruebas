# frozen_string_literal: true

class RemovePaymentInfoFromEnterprises < ActiveRecord::Migration[5.2]
  def change
    remove_column :enterprises, :merchant_id, :string
    remove_column :enterprises, :public_key, :string
    remove_column :enterprises, :secret_key, :string
    remove_column :enterprises, :email, :string
    remove_column :enterprises, :encrypted_password, :string
  end
end
