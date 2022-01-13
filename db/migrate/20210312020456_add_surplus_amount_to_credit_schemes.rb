# frozen_string_literal: true

class AddSurplusAmountToCreditSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_schemes, :surplus_amount_to_capital_time, :boolean, null: false, default: false
  end
end
