# frozen_string_literal: true

class RemoveBeforeKeyToStructures < ActiveRecord::Migration[5.2]
  def change
    remove_column :structures, :before_key
  end
end
