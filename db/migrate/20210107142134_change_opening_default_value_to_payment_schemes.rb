# frozen_string_literal: true

class ChangeOpeningDefaultValueToPaymentSchemes < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:payment_schemes, :opening_commission, from: nil, to: 0)
  end
end
