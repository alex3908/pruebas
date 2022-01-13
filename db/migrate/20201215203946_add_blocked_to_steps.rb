# frozen_string_literal: true

class AddBlockedToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :blocked, :boolean, default: false
  end
end
