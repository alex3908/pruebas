# frozen_string_literal: true

class AddEnterpriseToStages < ActiveRecord::Migration[5.2]
  def change
    add_reference :stages, :owner_enterprise, index: true, foreign_key: { to_table: "enterprises" }
  end
end
