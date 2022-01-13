# frozen_string_literal: true

class AddConceptToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :concept_key, :string, index: true
  end
end
