# frozen_string_literal: true

class CreateCommissionSchemesRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :commission_schemes_roles do |t|
      t.references :commission_scheme, foreign_key: true
      t.references :role, foreign_key: true
      t.references :folder_user_concept, foreign_key: true
      t.decimal :commission

      t.timestamps
    end
  end
end
