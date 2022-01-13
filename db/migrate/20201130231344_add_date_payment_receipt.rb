# frozen_string_literal: true

class AddDatePaymentReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :commissions, :date_payment_receipt, :date
  end
end
