# frozen_string_literal: true

class AddPurchaseConditionsToStage < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :purchase_conditions, :text
  end
end
