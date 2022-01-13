# frozen_string_literal: true

class AddMinDownPaymentAdvanceToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :min_down_payment_advance, :decimal, default: 1
  end
end
