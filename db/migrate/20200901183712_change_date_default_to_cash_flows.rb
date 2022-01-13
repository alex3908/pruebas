# frozen_string_literal: true

class ChangeDateDefaultToCashFlows < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:cash_flows, :date, from: DateTime.now, to: -> { "CURRENT_DATE" })
  end
end
