# frozen_string_literal: true

class AddActiveStageAnnexeToStage < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :stage_annexe, :boolean, default: false
  end
end
