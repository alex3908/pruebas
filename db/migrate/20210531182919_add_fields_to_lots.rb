# frozen_string_literal: true

class AddFieldsToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :blocks, :string
    add_column :lots, :geographic_location, :string
    add_column :lots, :ownership_percent, :integer
    add_column :lots, :coowners, :string
    add_column :lots, :liquidity, :string
  end
end
