# frozen_string_literal: true

class AddActiveLotAnnexeToStage < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :lot_annexe, :boolean, default: false
  end
end
