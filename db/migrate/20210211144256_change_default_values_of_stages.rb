# frozen_string_literal: true

class ChangeDefaultValuesOfStages < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:stages, :max_commission_amount, from: nil, to: 12)
    change_column_default(:stages, :initial_payment_expiration, from: nil, to: 1)
    change_column_default(:stages, :down_payment_expiration, from: nil, to: 120)
    change_column_default(:stages, :sudden_death, from: nil, to: 5)
  end
end
