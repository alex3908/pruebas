# frozen_string_literal: true

class ChangeCreditSchemeFields < ActiveRecord::Migration[5.2]
  def change
    change_column :credit_schemes, :min_down_payment, :integer
    change_column :credit_schemes, :max_down_payment_percentage, :integer
    change_column_default :credit_schemes, :min_down_payment, 10
    change_column_default :credit_schemes, :first_payment, 0
    change_column_default :credit_schemes, :max_finance, 0
    change_column_default :credit_schemes, :min_capital_payment, 0
    change_column_default :credit_schemes, :max_grace_months, 0
    change_column_default :credit_schemes, :max_delay_payments, 0
  end
end
