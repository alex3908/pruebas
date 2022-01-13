# frozen_string_literal: true

class AddJobDataToJobStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :job_statuses, :job_data, :hstore
  end
end
