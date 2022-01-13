# frozen_string_literal: true

class AddFolderUserConceptToFolderUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :folder_users, :folder_user_concept, foreign_key: true
  end
end
