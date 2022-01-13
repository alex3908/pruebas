# frozen_string_literal: true

class AddStepRefToFolders < ActiveRecord::Migration[5.2]
  def change
    add_reference :folders, :step, foreign_key: true
  end
end
