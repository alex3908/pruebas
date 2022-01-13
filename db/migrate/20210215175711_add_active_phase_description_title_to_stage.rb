# frozen_string_literal: true

class AddActivePhaseDescriptionTitleToStage < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :phase_description_title, :string
  end
end
