# frozen_string_literal: true

class AddConceptToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :concept, :string
  end
end
