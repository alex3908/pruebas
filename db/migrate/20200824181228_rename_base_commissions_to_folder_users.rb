# frozen_string_literal: true

class RenameBaseCommissionsToFolderUsers < ActiveRecord::Migration[5.2]
  def change
    rename_table :base_commissions, :folder_users
  end
end
