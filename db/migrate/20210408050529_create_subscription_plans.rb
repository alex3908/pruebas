# frozen_string_literal: true

class CreateSubscriptionPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :subscription_plans do |t|
      t.decimal :amount
      t.integer :payments_count
      t.string :concept_description
      t.string :paid_installment_ids, array: true, default: []
      t.date :start_date
      t.date :end_date
      t.references :subscription

      t.timestamps
    end
  end
end
