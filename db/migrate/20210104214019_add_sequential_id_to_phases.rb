# frozen_string_literal: true

class AddSequentialIdToPhases < ActiveRecord::Migration[5.2]
  def change
    add_column :phases, :sequential_id, :integer

    execute <<~SQL
      UPDATE phases
      SET sequential_id = old_phases.next_sequential_id
      FROM (
        SELECT id, ROW_NUMBER()
        OVER (
          PARTITION BY project_id
          ORDER BY id
        ) AS next_sequential_id
        FROM phases
      ) old_phases
      WHERE phases.id = old_phases.id
    SQL

    change_column :phases, :sequential_id, :integer, null: false
    add_index :phases, [:sequential_id, :project_id], unique: true
  end
end
