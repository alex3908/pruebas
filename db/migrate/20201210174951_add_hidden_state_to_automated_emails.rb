# frozen_string_literal: true

class AddHiddenStateToAutomatedEmails < ActiveRecord::Migration[5.2]
  def change
    add_column :automated_emails, :hidden_state, :string
  end
end
