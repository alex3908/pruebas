# frozen_string_literal: true

class AddSequentialIdToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :sequential_id, :integer

    execute <<~SQL
      UPDATE lots
      SET sequential_id = old_lots.next_sequential_id
      FROM (
        SELECT id, ROW_NUMBER()
        OVER (
          PARTITION BY stage_id
          ORDER BY id
        ) AS next_sequential_id
        FROM lots
      ) old_lots
      WHERE lots.id = old_lots.id
    SQL

    change_column :lots, :sequential_id, :integer, null: false
    add_index :lots, [:sequential_id, :stage_id], unique: true
  end
end
