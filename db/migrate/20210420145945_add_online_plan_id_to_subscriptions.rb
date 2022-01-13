# frozen_string_literal: true

class AddOnlinePlanIdToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :online_plan_id, :string
  end
end
