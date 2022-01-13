# frozen_string_literal: true

class AddAdjoiningsToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :adjoining_north, :string
    add_column :lots, :adjoining_south, :string
    add_column :lots, :adjoining_east, :string
    add_column :lots, :adjoining_west, :string
    add_column :lots, :north, :decimal
    add_column :lots, :south, :decimal
    add_column :lots, :east, :decimal
    add_column :lots, :west, :decimal
  end
end
