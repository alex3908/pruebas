# frozen_string_literal: true

class AddCanceledByToJobStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :job_statuses, :canceled_by, :integer, default: 0
    add_column :job_statuses, :canceled_at, :datetime, nil: true
  end
end
