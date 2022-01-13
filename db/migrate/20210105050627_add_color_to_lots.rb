# frozen_string_literal: true

class AddColorToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :color, :string
  end
end
