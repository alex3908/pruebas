# frozen_string_literal: true

class CreateDownPaymentsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :down_payments do |t|
      t.references :credit_scheme, index: true, foreign_key: true
      t.integer :term
      t.decimal :min
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
