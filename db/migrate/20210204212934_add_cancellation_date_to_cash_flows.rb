# frozen_string_literal: true

class AddCancellationDateToCashFlows < ActiveRecord::Migration[5.2]
  def change
    add_column :cash_flows, :cancellation_date, :datetime
  end
end
