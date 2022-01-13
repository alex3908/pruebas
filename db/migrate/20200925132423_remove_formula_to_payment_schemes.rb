# frozen_string_literal: true

class RemoveFormulaToPaymentSchemes < ActiveRecord::Migration[5.2]
  def change
    remove_column :payment_schemes, :formula, :string
  end
end
