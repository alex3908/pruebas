# frozen_string_literal: true

class AddCommentsToFileApprovals < ActiveRecord::Migration[5.2]
  def change
    add_column :file_approvals, :comment, :string
  end
end
