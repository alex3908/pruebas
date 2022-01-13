# frozen_string_literal: true

class AddPaymentMethodToCashBacks < ActiveRecord::Migration[5.2]
  def change
    add_reference :cash_backs, :payment_method, index: true, foreign_key: true
  end
end
