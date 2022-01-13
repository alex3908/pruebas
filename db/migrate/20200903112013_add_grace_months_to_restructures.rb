# frozen_string_literal: true

class AddGraceMonthsToRestructures < ActiveRecord::Migration[5.2]
  def change
    add_column :restructures, :grace_months, :integer, default: 0
  end
end
