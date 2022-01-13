# frozen_string_literal: true

class RemoveCompanyNameToMoralClients < ActiveRecord::Migration[5.2]
  def change
    remove_column :moral_clients, :company_name
  end
end
