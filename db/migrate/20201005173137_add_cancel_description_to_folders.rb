# frozen_string_literal: true

class AddCancelDescriptionToFolders < ActiveRecord::Migration[5.2]
  def change
    add_column :folders, :canceled_description, :string
    add_column :folders, :canceled_by, :bigint
    add_column :folders, :canceled_date, :datetime

    add_foreign_key :folders, :users, column: :canceled_by
  end
end
