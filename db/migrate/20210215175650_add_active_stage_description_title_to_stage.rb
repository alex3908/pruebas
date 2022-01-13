# frozen_string_literal: true

class AddActiveStageDescriptionTitleToStage < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :stage_description_title, :string
  end
end
