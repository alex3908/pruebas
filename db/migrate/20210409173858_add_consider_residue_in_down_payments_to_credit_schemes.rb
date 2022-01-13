# frozen_string_literal: true

class AddConsiderResidueInDownPaymentsToCreditSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_schemes, :consider_residue_in_down_payments, :bool, default: false
  end
end
