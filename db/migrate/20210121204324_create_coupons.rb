# frozen_string_literal: true

class CreateCoupons < ActiveRecord::Migration[5.2]
  def change
    create_table :coupons do |t|
      t.references :promotion, foreign_key: true
      t.string :promotion_code
      t.boolean :draft, default: :true
      t.string :status
      t.integer :usage_limit
      t.integer :usages, default: 0
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
