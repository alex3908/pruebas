# frozen_string_literal: true

class AddLotEntityNameToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :lot_entity_name, :string, default: "Lote"
  end
end
