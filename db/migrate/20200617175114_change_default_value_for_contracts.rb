# frozen_string_literal: true

class ChangeDefaultValueForContracts < ActiveRecord::Migration[5.2]
  def change
    change_column_default :contracts, :min_amount, 0
    change_column_default :contracts, :min_metrics, 0
    change_column_default :contracts, :data_type, "html"
  end
end
