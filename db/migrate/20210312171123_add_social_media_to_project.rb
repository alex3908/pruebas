# frozen_string_literal: true

class AddSocialMediaToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :facebook, :string
    add_column :projects, :instagram, :string
    add_column :projects, :website, :string
  end
end
