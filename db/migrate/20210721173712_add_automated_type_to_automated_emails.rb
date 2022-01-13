# frozen_string_literal: true

class AddAutomatedTypeToAutomatedEmails < ActiveRecord::Migration[5.2]
  def change
    add_column :automated_emails, :automated_type, :string
    add_column :automated_emails, :delivery_in, :integer, default: 0
  end
end
