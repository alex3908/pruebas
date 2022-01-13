# frozen_string_literal: true

class CreateClassifiersRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :classifiers_roles do |t|
      t.references :role, foreign_key: true
      t.references :classifier, foreign_key: true
    end
  end
end
