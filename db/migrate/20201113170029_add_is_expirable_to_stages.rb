# frozen_string_literal: true

class AddIsExpirableToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :is_expirable, :boolean, default: true
  end
end
