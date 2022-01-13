# frozen_string_literal: true

class AddShowPercentageToPromotion < ActiveRecord::Migration[5.2]
  def change
    add_column :promotions, :show_percentage, :boolean, default: true
  end
end
