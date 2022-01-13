# frozen_string_literal: true

class AddRoleToFolderUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :folder_users, :role, index: true, foreign_key: true
  end
end
