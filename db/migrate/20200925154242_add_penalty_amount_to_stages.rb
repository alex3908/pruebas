# frozen_string_literal: true

class AddPenaltyAmountToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :penalty_amount, :decimal, default: 0
  end
end
