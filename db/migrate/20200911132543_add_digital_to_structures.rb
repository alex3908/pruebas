# frozen_string_literal: true

class AddDigitalToStructures < ActiveRecord::Migration[5.2]
  def change
    add_column :structures, :digital, :boolean, null: false, default: false
  end
end
