# frozen_string_literal: true

class AddDescriptionToJobStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :job_statuses, :description, :text
  end
end
