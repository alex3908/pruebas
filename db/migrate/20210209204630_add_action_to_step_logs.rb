# frozen_string_literal: true

class AddActionToStepLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :step_logs, :action, :string
  end
end
