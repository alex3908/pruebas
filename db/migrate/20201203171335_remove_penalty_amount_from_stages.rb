# frozen_string_literal: true

class RemovePenaltyAmountFromStages < ActiveRecord::Migration[5.2]
  def change
    remove_column :stages, :penalty_amount
  end
end
