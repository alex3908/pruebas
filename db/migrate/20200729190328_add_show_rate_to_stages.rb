# frozen_string_literal: true

class AddShowRateToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :show_rate, :boolean, default: false
  end
end
