# frozen_string_literal: true

class AddDraftToPromotions < ActiveRecord::Migration[5.2]
  def change
    add_column :promotions, :draft, :boolean, default: :true
  end
end
