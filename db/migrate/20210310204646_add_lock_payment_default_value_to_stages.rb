# frozen_string_literal: true

class AddLockPaymentDefaultValueToStages < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:credit_schemes, :lock_payment, from: nil, to: 0)
  end
end
