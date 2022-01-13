# frozen_string_literal: true

class AddAllowUpdateToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :allow_update, :boolean, default: false
  end
end
