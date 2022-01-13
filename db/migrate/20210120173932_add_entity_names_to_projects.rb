# frozen_string_literal: true

class AddEntityNamesToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :project_entity_name, :string, default: "Proyecto"
    add_column :projects, :phase_entity_name, :string, default: "Fase"
    add_column :projects, :stage_entity_name, :string, default: "Etapa"
  end
end
