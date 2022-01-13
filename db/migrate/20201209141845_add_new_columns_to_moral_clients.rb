# frozen_string_literal: true

class AddNewColumnsToMoralClients < ActiveRecord::Migration[5.2]
  def change
    add_column :moral_clients, :notary_public_name, :string
    add_column :moral_clients, :notary_public_number, :string
    add_column :moral_clients, :notary_public_catalog_republic, :string
    add_column :moral_clients, :commercial_electronic_folio_number, :string
    add_column :moral_clients, :public_registry_state, :string
    add_column :moral_clients, :public_registry_date, :date
  end
end
