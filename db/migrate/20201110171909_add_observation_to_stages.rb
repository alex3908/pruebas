# frozen_string_literal: true

class AddObservationToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :observations, :text
  end
end
