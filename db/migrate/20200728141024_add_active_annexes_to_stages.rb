# frozen_string_literal: true

class AddActiveAnnexesToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :active_annexes, :boolean, default: false
  end
end
