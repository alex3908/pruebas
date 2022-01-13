# frozen_string_literal: true

class AddPaymentMethodToBaseCommissions < ActiveRecord::Migration[5.2]
  def change
    add_reference :base_commissions, :payment_method, index: true, foreign_key: true
  end
end
