# frozen_string_literal: true

class AddDeleteAtToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :deleted_at, :datetime
  end
end
