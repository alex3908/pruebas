# frozen_string_literal: true

class RemoveSequentialIdToModels < ActiveRecord::Migration[5.2]
  def change
    remove_column :lots, :sequential_id
    remove_column :stages, :sequential_id
    remove_column :phases, :sequential_id
    remove_column :folders, :sequential_id
  end
end
