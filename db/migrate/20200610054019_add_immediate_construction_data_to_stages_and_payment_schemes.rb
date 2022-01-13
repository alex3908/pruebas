# frozen_string_literal: true

class AddImmediateConstructionDataToStagesAndPaymentSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :immediate_extra_months, :integer, default: 0
    add_column :stages, :max_percent_immediate_lots_sold, :integer, default: 20

    add_column :payment_schemes, :immediate_extra_months, :integer, default: 0
  end
end
