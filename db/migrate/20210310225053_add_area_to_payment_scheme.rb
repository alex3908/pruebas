# frozen_string_literal: true

class AddAreaToPaymentScheme < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_schemes, :area, :decimal
  end
end
