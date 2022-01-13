# frozen_string_literal: true

class AddHiddenToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :hidden, :boolean, null: false, default: false
  end
end
