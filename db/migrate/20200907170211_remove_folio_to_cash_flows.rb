# frozen_string_literal: true

class RemoveFolioToCashFlows < ActiveRecord::Migration[5.2]
  def change
    remove_column :cash_flows, :folio, :string
  end
end
