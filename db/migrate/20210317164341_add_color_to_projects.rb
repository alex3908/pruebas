# frozen_string_literal: true

class AddColorToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :color, :string, default: "#000000"
    add_column :projects, :subtitle_color, :string, default: "#000000"
    add_column :projects, :divider_color, :string, default: "#000000"
    add_column :projects, :font_color, :string, default: "#FFFFFF"
  end
end
