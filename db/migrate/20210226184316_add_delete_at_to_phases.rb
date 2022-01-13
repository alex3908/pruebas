# frozen_string_literal: true

class AddDeleteAtToPhases < ActiveRecord::Migration[5.2]
  def change
    add_column :phases, :deleted_at, :datetime
  end
end
