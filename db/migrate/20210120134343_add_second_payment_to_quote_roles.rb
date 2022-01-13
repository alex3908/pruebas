# frozen_string_literal: true

class AddSecondPaymentToQuoteRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :quote_roles, :min_days_second_monthly_payment, :integer
    add_column :quote_roles, :max_days_second_monthly_payment, :integer
  end
end
