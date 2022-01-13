# frozen_string_literal: true

class AddBankAccountAndPaymentMethodToOnlinePaymentService < ActiveRecord::Migration[5.2]
  def change
    add_reference :online_payment_services, :bank_account, index: true, foreign_key: true
    add_reference :online_payment_services, :payment_method, index: true, foreign_key: true
  end
end
