# frozen_string_literal: true

class AddConceptToBaseCommissions < ActiveRecord::Migration[5.2]
  def change
    add_column :base_commissions, :concept, :string
  end
end
