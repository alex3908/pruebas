# frozen_string_literal: true

class AddAncestryToStructures < ActiveRecord::Migration[5.2]
  def change
    rename_column :structures, :parent_id, :ancestry
    change_column :structures, :ancestry, :string
    add_index :structures, :ancestry
  end
end
