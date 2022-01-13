# frozen_string_literal: true

class AddWithoutPromotionsToRestructures < ActiveRecord::Migration[5.2]
  def change
    add_column :restructures, :without_promotions, :boolean, default: false
    remove_column :payment_schemes, :with_promotions, :boolean, default: true
  end
end
