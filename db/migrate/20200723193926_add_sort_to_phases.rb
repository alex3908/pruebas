# frozen_string_literal: true

class AddSortToPhases < ActiveRecord::Migration[5.2]
  def change
    add_column :phases, :sort, :integer
  end
end
