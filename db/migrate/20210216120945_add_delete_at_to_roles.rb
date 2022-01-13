# frozen_string_literal: true

class AddDeleteAtToRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :deleted_at, :datetime
  end
end
