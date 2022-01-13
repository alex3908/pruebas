# frozen_string_literal: true

class RemoveProjectsFromContracts < ActiveRecord::Migration[5.2]
  def change
    remove_column :contracts, :project_id
  end
end
