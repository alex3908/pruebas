# frozen_string_literal: true

class AddInteriorNumberToPhysicalClients < ActiveRecord::Migration[5.2]
  def change
    add_column :physical_clients, :validity_identification, :string
    add_column :physical_clients, :interior_number, :string, after: :house_number
  end
end
