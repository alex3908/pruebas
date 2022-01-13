# frozen_string_literal: true

class AddFolderUserConceptToAutomatedEmail < ActiveRecord::Migration[5.2]
  def change
    remove_column :automated_emails, :folder_user, :string
    add_reference :automated_emails, :folder_user_concept, foreign_key: true, after: :emails_information
  end
end
