# frozen_string_literal: true

class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :var, :string
    add_index :settings, %i(var), unique: true
  end
end
