# frozen_string_literal: true

class AddPaymentToCommission < ActiveRecord::Migration[5.2]
  def change
    add_reference :commissions, :payment, index: true, foreign_key: true
  end
end
