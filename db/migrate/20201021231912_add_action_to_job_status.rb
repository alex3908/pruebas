# frozen_string_literal: true

class AddActionToJobStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :job_statuses, :action, :integer, default: 0
  end
end
