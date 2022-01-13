# frozen_string_literal: true

class AddCashBackToCashFlows < ActiveRecord::Migration[5.2]
  def change
    add_column :cash_flows, :cash_back, :boolean, default: false
  end
end
