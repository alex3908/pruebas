# frozen_string_literal: true

class AddBranchToOnlinePaymentServices < ActiveRecord::Migration[5.2]
  def change
    add_reference :online_payment_services, :branch, index: true, foreign_key: true
  end
end
