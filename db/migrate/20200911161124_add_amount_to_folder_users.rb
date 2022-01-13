# frozen_string_literal: true

class AddAmountToFolderUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :folder_users, :amount, :decimal, default: 0
  end
end
