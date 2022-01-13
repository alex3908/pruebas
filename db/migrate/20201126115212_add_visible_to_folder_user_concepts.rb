# frozen_string_literal: true

class AddVisibleToFolderUserConcepts < ActiveRecord::Migration[5.2]
  def change
    add_column :folder_user_concepts, :visible, :boolean, default: true
  end
end
