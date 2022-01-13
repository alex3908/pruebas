# frozen_string_literal: true

class AddCreditSchemeAttributesToPaymentSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_schemes, :compound_interest, :boolean, default: true
    add_column :payment_schemes, :independent_initial_payment, :boolean, default: true
    add_column :payment_schemes, :delivery_date, :date
    add_column :payment_schemes, :second_payment, :integer, default: 0
    add_column :payment_schemes, :initial_payment_active, :boolean, default: true
  end
end
