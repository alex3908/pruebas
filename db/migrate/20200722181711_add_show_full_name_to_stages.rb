# frozen_string_literal: true

class AddShowFullNameToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :show_full_name, :boolean, default: true
  end
end
