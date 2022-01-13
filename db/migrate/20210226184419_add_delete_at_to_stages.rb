# frozen_string_literal: true

class AddDeleteAtToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :deleted_at, :datetime
  end
end
