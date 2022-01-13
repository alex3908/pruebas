# frozen_string_literal: true

class AddHiddenToRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :hidden, :boolean, null: false, default: false
  end
end
