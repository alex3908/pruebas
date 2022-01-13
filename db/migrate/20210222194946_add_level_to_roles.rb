# frozen_string_literal: true

class AddLevelToRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :level, :integer, null: true
  end
end
