# frozen_string_literal: true

class AddOnlinePaymentServiceToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_reference :subscriptions, :online_payment_service, index: true, foreign_key: true
  end
end
