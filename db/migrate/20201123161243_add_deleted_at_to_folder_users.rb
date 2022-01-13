# frozen_string_literal: true

class AddDeletedAtToFolderUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :folder_users, :deleted_at, :datetime
  end
end
