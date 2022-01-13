# frozen_string_literal: true

class AddIsRelativeFinancingToPaymentScheme < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_schemes, :is_relative_financing, :boolean, default: false
  end
end
