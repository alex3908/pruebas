# frozen_string_literal: true

class RemoveAnnexeToStages < ActiveRecord::Migration[5.2]
  def change
    remove_column :stages, :lot_annexe, :boolean, default: false
    remove_column :stages, :stage_annexe, :boolean, default: false
    remove_column :stages, :phase_annexe, :boolean, default: false
  end
end
