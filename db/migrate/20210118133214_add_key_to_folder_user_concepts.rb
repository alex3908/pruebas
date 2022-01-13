# frozen_string_literal: true

class AddKeyToFolderUserConcepts < ActiveRecord::Migration[5.2]
  def change
    add_column :folder_user_concepts, :key, :string
  end
end
