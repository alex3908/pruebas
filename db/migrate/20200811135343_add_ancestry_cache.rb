# frozen_string_literal: true

class AddAncestryCache < ActiveRecord::Migration[5.2]
  def change
    add_column :structures, :ancestry_depth, :integer, default: 0
  end
end
