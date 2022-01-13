# frozen_string_literal: true

class AddActiveAmortizationTableToContract < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :active_amortization_table, :boolean, default: false
  end
end
