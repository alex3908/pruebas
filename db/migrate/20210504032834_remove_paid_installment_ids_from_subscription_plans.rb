# frozen_string_literal: true

class RemovePaidInstallmentIdsFromSubscriptionPlans < ActiveRecord::Migration[5.2]
  def change
    remove_column :subscription_plans, :paid_installment_ids, :string
  end
end
