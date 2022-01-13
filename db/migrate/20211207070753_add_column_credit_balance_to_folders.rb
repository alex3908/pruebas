# frozen_string_literal: true

class AddColumnCreditBalanceToFolders < ActiveRecord::Migration[5.2]
  def change
    add_column :folders, :credit_balance, :boolean, default: false
  end
end
