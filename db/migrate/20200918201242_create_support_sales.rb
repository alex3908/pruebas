# frozen_string_literal: true

class CreateSupportSales < ActiveRecord::Migration[5.2]
  def change
    create_table :support_sales do |t|
      t.string :status, null: false

      t.references :folder, index: true, null: false, foreign_key: true
      t.references :requester, index: true, null: false, foreign_key: { to_table: "users" }
      t.references :supporter, index: true, null: true, foreign_key: { to_table: "users" }
      t.references :support_coordinator, index: true, null: true, foreign_key: { to_table: "users" }
      t.references :support_manager, index: true, null: true, foreign_key: { to_table: "users" }

      t.timestamps
    end
  end
end
