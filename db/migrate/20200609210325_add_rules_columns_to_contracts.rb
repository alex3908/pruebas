# frozen_string_literal: true

class AddRulesColumnsToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :max_amount, :integer
    add_column :contracts, :min_amount, :integer

    add_column :contracts, :max_metrics, :integer
    add_column :contracts, :min_metrics, :integer

    add_column :contracts, :client_gender, :integer
    add_column :contracts, :max_owners, :integer
    add_column :contracts, :lot_type, :integer
    add_column :contracts, :client_nationality, :integer
    add_column :contracts, :periods_amount, :integer
    add_column :contracts, :client_type, :integer
    add_column :contracts, :financing_type, :integer
  end
end
