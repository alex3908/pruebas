# frozen_string_literal: true

class AddExtraAdjoiningsToLot < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :adjoining_northeast, :string
    add_column :lots, :adjoining_southeast, :string
    add_column :lots, :adjoining_northwest, :string
    add_column :lots, :adjoining_southwest, :string
    add_column :lots, :northeast, :decimal
    add_column :lots, :southeast, :decimal
    add_column :lots, :northwest, :decimal
    add_column :lots, :southwest, :decimal
  end
end
