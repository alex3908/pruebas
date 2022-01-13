# frozen_string_literal: true

class AddExclusiveFolderToCashBacks < ActiveRecord::Migration[5.2]
  def change
    add_reference :cash_backs, :exclusive_folder, index: true, null: true, foreign_key: { to_table: "folders" }
  end
end
