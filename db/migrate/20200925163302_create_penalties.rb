# frozen_string_literal: true

class CreatePenalties < ActiveRecord::Migration[5.2]
  def change
    create_table :penalties do |t|
      t.references :installment, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.bigint :canceled_by
      t.boolean :active, default: true
      t.decimal :amount

      t.timestamps
    end
    add_foreign_key :penalties, :users, column: :canceled_by
  end
end
