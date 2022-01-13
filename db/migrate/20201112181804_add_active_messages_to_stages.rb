# frozen_string_literal: true

class AddActiveMessagesToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :active_messages, :boolean, default: true
  end
end
