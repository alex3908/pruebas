# frozen_string_literal: true

class AddDeletedAtToPromotions < ActiveRecord::Migration[5.2]
  def change
    add_column :promotions, :deleted_at, :datetime
  end
end
