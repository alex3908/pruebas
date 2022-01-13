# frozen_string_literal: true

class ChangeUserIdDefaultForStepLog < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:step_logs, :user_id, true)
  end
end
