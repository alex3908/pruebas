# frozen_string_literal: true

class AddSortToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :sort, :integer
  end
end
