# frozen_string_literal: true

class ChangeMaxCommissionDefaultToStages < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:stages, :max_commission_amount, from: 12, to: 0)
  end
end
