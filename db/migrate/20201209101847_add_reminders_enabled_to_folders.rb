# frozen_string_literal: true

class AddRemindersEnabledToFolders < ActiveRecord::Migration[5.2]
  def change
    add_column :folders, :reminders_enabled, :boolean, default: true
  end
end
