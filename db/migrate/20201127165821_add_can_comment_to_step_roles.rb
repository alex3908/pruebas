# frozen_string_literal: true

class AddCanCommentToStepRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :step_roles, :can_comment, :boolean, default: true
  end
end
