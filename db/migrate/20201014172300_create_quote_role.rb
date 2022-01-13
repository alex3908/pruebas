# frozen_string_literal: true

class CreateQuoteRole < ActiveRecord::Migration[5.2]
  def change
    create_table :quote_roles do |t|
      t.references :role, index: true, null: false, foreign_key: true
      t.integer :min_months_deferred_down_payment
      t.integer :max_months_deferred_down_payment
      t.integer :min_days_first_monthly_payment
      t.integer :max_days_first_monthly_payment

      t.timestamps
    end
  end
end
