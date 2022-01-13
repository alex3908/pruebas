# frozen_string_literal: true

class CreateCashBackFlows < ActiveRecord::Migration[5.2]
  def change
    create_table :cash_back_flows do |t|
      t.references :cash_back, index: true, foreign_key: true
      t.references :cash_flow, index: true, foreign_key: true
      t.decimal :amount_used, null: true
      t.decimal :balance_after, null: true

      t.timestamps
    end
  end
end
