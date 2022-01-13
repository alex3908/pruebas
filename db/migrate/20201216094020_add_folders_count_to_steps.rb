# frozen_string_literal: true

class AddFoldersCountToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :folders_count, :integer, default: 0

    Step.all.each do |step|
      Step.reset_counters(step.id, :folders)
    end
  end
end
