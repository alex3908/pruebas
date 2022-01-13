# frozen_string_literal: true

class AddOnlinePaymentsEnabledToEnterprise < ActiveRecord::Migration[5.2]
  def change
    add_column :enterprises, :online_payments_enabled, :boolean, default: false
  end
end
