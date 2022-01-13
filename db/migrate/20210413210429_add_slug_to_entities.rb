# frozen_string_literal: true

class AddSlugToEntities < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :slug, :string
    add_column :phases, :slug, :string
    add_column :stages, :slug, :string

    add_index :projects, [:slug], unique: true
    add_index :phases, [:slug, :project_id], unique: true
    add_index :stages, [:slug, :phase_id], unique: true
  end
end
