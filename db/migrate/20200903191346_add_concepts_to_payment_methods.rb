# frozen_string_literal: true

class AddConceptsToPaymentMethods < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_methods, :capital, :boolean, default: false
    add_column :payment_methods, :down_payment, :boolean, default: false
    add_column :payment_methods, :interest, :boolean, default: false
  end
end
