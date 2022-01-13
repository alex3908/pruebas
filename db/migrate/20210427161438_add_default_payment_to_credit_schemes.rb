# frozen_string_literal: true

class AddDefaultPaymentToCreditSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_schemes, :default_payment, :integer
  end
end
