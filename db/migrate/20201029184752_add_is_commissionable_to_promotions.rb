# frozen_string_literal: true

class AddIsCommissionableToPromotions < ActiveRecord::Migration[5.2]
  def change
    add_column :promotions, :is_commissionable, :boolean, default: true
  end
end
