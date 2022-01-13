# frozen_string_literal: true

class AddClientToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_reference :subscriptions, :client, index: true, foreign_key: true
    add_column :subscriptions, :billing_start, :date
    add_column :subscriptions, :billing_end, :date
  end
end
