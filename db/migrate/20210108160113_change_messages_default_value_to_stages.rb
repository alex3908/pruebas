# frozen_string_literal: true

class ChangeMessagesDefaultValueToStages < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:stages, :active_messages, from: true, to: false)
    change_column_default(:stages, :is_expirable, from: true, to: false)
    change_column_default(:stages, :active_mails, from: true, to: false)
  end
end
