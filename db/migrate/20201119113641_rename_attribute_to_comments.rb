# frozen_string_literal: true

class RenameAttributeToComments < ActiveRecord::Migration[5.2]
  def change
    rename_column :comments, :reason, :message
  end
end
