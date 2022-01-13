# frozen_string_literal: true

class AddCreditSchemeToPaymentPlans < ActiveRecord::Migration[5.2]
  def change
    add_reference :payment_plans, :credit_scheme, index: true, foreign_key: true
  end
end
