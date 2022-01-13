# frozen_string_literal: true

class ChangeLastUpdateDefaultToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:subscriptions, :last_update, from: DateTime.now, to: -> { "CURRENT_DATE" })
  end
end
