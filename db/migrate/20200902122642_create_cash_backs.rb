# frozen_string_literal: true

class CreateCashBacks < ActiveRecord::Migration[5.2]
  def change
    create_table :cash_backs do |t|
      t.references :client, index: true, null: true, foreign_key: true
      t.references :user, index: true, null: true, foreign_key: true
      t.decimal :amount, null: true
      t.string :status, null: false
      t.string :canceled_by, null: true
      t.timestamps
    end
  end
end
