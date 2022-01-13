# frozen_string_literal: true

class AddDeletedAtToPaymentPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_plans, :deleted_at, :datetime
  end
end
