# frozen_string_literal: true

class AddDeleteAtToStructures < ActiveRecord::Migration[5.2]
  def change
    add_column :structures, :deleted_at, :datetime
  end
end
