# frozen_string_literal: true

class AddCompanyNameToMoralClients < ActiveRecord::Migration[5.2]
  def change
    add_column :moral_clients, :company_name, :string
  end
end
