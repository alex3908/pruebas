# frozen_string_literal: true

class AddMoreAttributesToLot < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :colloquial_name, :string
    add_column :lots, :identification_name, :string
    add_column :lots, :owner_name, :string
    add_column :lots, :acquisition_cost, :decimal
    add_column :lots, :market_price, :decimal
    add_column :lots, :exchange_rate, :decimal
    add_column :lots, :vocation, :string
    add_column :lots, :descriptive_status, :string
  end
end
