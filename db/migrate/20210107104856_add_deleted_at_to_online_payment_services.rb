# frozen_string_literal: true

class AddDeletedAtToOnlinePaymentServices < ActiveRecord::Migration[5.2]
  def change
    add_column :online_payment_services, :deleted_at, :datetime
  end
end
