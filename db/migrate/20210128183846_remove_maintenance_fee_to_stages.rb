# frozen_string_literal: true

class RemoveMaintenanceFeeToStages < ActiveRecord::Migration[5.2]
  def change
    remove_column :stages, :maintenance_fee
  end
end
