# frozen_string_literal: true

class AddSequentialIdToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :sequential_id, :integer

    execute <<~SQL
      UPDATE stages
      SET sequential_id = old_stages.next_sequential_id
      FROM (
        SELECT id, ROW_NUMBER()
        OVER (
          PARTITION BY phase_id
          ORDER BY id
        ) AS next_sequential_id
        FROM stages
      ) old_stages
      WHERE stages.id = old_stages.id
    SQL

    change_column :stages, :sequential_id, :integer, null: false
    add_index :stages, [:sequential_id, :phase_id], unique: true
  end
end
