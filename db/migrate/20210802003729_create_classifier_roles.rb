# frozen_string_literal: true

class CreateClassifierRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :classifier_roles do |t|
      t.references :classifier, index: true, foreign_key: true
      t.references :role, index: true, foreign_key: true
      t.timestamps
    end
  end
end
