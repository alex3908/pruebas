# frozen_string_literal: true

class AddSortToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :sort, :integer
  end
end
