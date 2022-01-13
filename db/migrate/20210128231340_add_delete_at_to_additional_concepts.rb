# frozen_string_literal: true

class AddDeleteAtToAdditionalConcepts < ActiveRecord::Migration[5.2]
  def change
    add_column :additional_concepts, :deleted_at, :datetime
  end
end
