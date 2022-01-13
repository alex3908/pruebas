# frozen_string_literal: true

class AddQuotationAttributesToCreditScheme < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_schemes, :formula, :string
    add_column :credit_schemes, :first_payment, :integer
    add_column :credit_schemes, :lock_payment, :decimal
    add_column :credit_schemes, :initial_payment, :decimal
    add_column :credit_schemes, :price, :decimal
    add_column :credit_schemes, :min_capital_payment, :decimal
    add_column :credit_schemes, :min_down_payment_advance, :decimal
    add_column :credit_schemes, :start_date_by, :string
    add_column :credit_schemes, :max_grace_months, :integer
    add_column :credit_schemes, :max_delay_payments, :integer
    add_column :credit_schemes, :show_rate, :boolean
    add_column :credit_schemes, :show_price, :boolean
    add_column :credit_schemes, :relative_discount, :boolean
    add_column :credit_schemes, :immediate_extra_months, :integer, default: 0
    add_column :credit_schemes, :max_percent_immediate_lots_sold, :integer
    add_column :credit_schemes, :min_down_payment, :decimal
    add_column :credit_schemes, :relative_down_payment, :boolean, default: false
    add_column :credit_schemes, :delivery_date, :date
    add_column :credit_schemes, :max_finance, :integer
    add_column :credit_schemes, :start_installments, :integer
    add_column :credit_schemes, :initial_payment_active, :boolean, default: true
    add_column :credit_schemes, :independent_initial_payment, :boolean, default: true
    add_column :credit_schemes, :second_payment, :decimal, default: 0
    add_column :credit_schemes, :max_down_payment_percentage, :decimal, default: 90
    add_column :credit_schemes, :down_payment_editable, :boolean, default: true
    add_column :credit_schemes, :initial_payment_editable, :boolean, default: true
  end
end
