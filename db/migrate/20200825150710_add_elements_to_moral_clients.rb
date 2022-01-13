# frozen_string_literal: true

class AddElementsToMoralClients < ActiveRecord::Migration[5.2]
  def change
    add_column :moral_clients, :nationality, :string
    add_column :moral_clients, :country_nationality, :string
    add_column :moral_clients, :identification_type, :string
    add_column :moral_clients, :company_identification_type, :string
    add_column :moral_clients, :identification_number, :string
    add_column :moral_clients, :company_identification_number, :string
    add_column :moral_clients, :validity_identification, :string
    add_column :moral_clients, :company_validity_identification, :string
    add_column :moral_clients, :constitution_date, :date
    add_column :moral_clients, :birthdate, :date
    add_column :moral_clients, :activity, :string
  end
end
