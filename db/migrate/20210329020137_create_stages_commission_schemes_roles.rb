# frozen_string_literal: true

class CreateStagesCommissionSchemesRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :stages_commission_schemes_roles do |t|
      t.references :stage, foreign_key: true
      t.references :commission_schemes_role, foreign_key: true, index: { name: "index_stagescommissionschemesroles_on_commissionschemesroleid" }
      t.string :users, array: true, default: []

      t.timestamps
    end
  end
end
