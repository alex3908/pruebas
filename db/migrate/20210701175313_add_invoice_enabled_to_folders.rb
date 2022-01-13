# frozen_string_literal: true

class AddInvoiceEnabledToFolders < ActiveRecord::Migration[5.2]
  def change
    add_column :folders, :invoice_enabled, :boolean, default: true
  end
end
