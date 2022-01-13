# frozen_string_literal: true

class CreateFolderUserConcepts < ActiveRecord::Migration[5.2]
  def change
    create_table :folder_user_concepts do |t|
      t.string :name
      t.decimal :commission, default: 0
      t.timestamps
    end
  end
end
