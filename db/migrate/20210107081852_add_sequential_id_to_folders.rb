# frozen_string_literal: true

class AddSequentialIdToFolders < ActiveRecord::Migration[5.2]
  def change
    add_column :folders, :sequential_id, :integer

    execute <<~SQL
      UPDATE folders
      SET sequential_id = old_folders.next_sequential_id
      FROM (
        SELECT id, ROW_NUMBER()
        OVER (
          PARTITION BY lot_id
          ORDER BY id
        ) AS next_sequential_id
        FROM folders
      ) old_folders
      WHERE folders.id = old_folders.id
    SQL

    change_column :folders, :sequential_id, :integer, null: false
    add_index :folders, [:sequential_id, :lot_id], unique: true
  end
end
