# frozen_string_literal: true

class AddActivePhaseAnnexeToStage < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :phase_annexe, :boolean, default: false
  end
end
