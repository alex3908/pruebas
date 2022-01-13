# frozen_string_literal: true

class AddDelayMonthsToRestructures < ActiveRecord::Migration[5.2]
  def change
    add_column :restructures, :delay_months, :integer, default: 0
  end
end
