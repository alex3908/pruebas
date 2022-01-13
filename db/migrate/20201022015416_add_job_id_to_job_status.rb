# frozen_string_literal: true

class AddJobIdToJobStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :job_statuses, :job_id, :integer, default: 0
  end
end
