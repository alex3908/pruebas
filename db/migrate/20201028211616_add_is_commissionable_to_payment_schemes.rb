# frozen_string_literal: true

class AddIsCommissionableToPaymentSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_schemes, :is_commissionable, :boolean, default: true
  end
end
