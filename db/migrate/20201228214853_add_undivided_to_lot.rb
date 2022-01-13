# frozen_string_literal: true

class AddUndividedToLot < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :undivided, :string
  end
end
