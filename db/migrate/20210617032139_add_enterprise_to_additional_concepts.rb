# frozen_string_literal: true

class AddEnterpriseToAdditionalConcepts < ActiveRecord::Migration[5.2]
  def change
    add_reference :additional_concepts, :enterprise, foreign_key: true, index: true
  end
end
