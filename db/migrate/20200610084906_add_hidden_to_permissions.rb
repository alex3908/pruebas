# frozen_string_literal: true

class AddHiddenToPermissions < ActiveRecord::Migration[5.2]
  def change
    add_column :permissions, :hidden, :boolean, null: false, default: false
  end
end
