# frozen_string_literal: true

class AddMaxGraceMonthsToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :max_grace_months, :integer, default: 0
  end
end
