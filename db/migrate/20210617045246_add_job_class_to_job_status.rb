# frozen_string_literal: true

class AddJobClassToJobStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :job_statuses, :job_class, :string
  end
end
