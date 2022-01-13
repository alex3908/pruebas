# frozen_string_literal: true

class RenamePaymentPlanToDiscount < ActiveRecord::Migration[5.2]
  def change
    rename_table :payment_plans, :discounts
  end
end
