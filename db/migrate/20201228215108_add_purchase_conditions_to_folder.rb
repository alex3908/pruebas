# frozen_string_literal: true

class AddPurchaseConditionsToFolder < ActiveRecord::Migration[5.2]
  def change
    add_column :folders, :purchase_conditions, :text
  end
end
