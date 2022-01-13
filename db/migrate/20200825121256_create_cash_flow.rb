# frozen_string_literal: true

class CreateCashFlow < ActiveRecord::Migration[5.2]
  def change
    create_table :cash_flows do |t|
      t.references :folder, index: true, null: true, foreign_key: true
      t.references :client, index: true, null: true, foreign_key: true
      t.references :branch, index: true, null: true, foreign_key: true
      t.references :user, index: true, null: true, foreign_key: true
      t.references :payment_method, index: true, null: true, foreign_key: true
      t.references :bank_account, index: true, null: true, foreign_key: true
      t.date :date, default: DateTime.now, null: false
      t.decimal :amount, null: true
      t.string :folio, null: false
      t.string :status, null: false
      t.string :canceled_by, null: true
      t.string :charge_id, null: true
      t.timestamps
    end
  end
end
