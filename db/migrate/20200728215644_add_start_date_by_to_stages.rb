# frozen_string_literal: true

class AddStartDateByToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :start_date_by, :string
  end
end
