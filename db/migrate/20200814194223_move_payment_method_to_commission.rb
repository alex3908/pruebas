# frozen_string_literal: true

class MovePaymentMethodToCommission < ActiveRecord::Migration[5.2]
  def change
    remove_reference :base_commissions, :payment_method, index: true, foreign_key: true
    add_reference :commissions, :payment_method, index: true, foreign_key: true
  end
end
