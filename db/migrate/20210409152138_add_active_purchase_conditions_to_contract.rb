# frozen_string_literal: true

class AddActivePurchaseConditionsToContract < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :active_purchase_conditions, :boolean, default: true
  end
end
