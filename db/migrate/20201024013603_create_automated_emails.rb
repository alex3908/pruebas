# frozen_string_literal: true

class CreateAutomatedEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :automated_emails do |t|
      t.references :step, foreign_key: true
      t.references :email_template, foreign_key: true
      t.string :reciever_type
      t.string :execution_type
      t.string :folder_user
      t.string :emails_information, array: true
      t.timestamps
    end
  end
end
