# frozen_string_literal: true

class AddVisibleToFolderUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :folder_users, :visible, :boolean, default: true
  end
end
