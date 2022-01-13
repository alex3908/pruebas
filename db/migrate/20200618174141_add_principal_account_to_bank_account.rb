# frozen_string_literal: true

class AddPrincipalAccountToBankAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_accounts, :principal, :boolean, default: false
  end
end
