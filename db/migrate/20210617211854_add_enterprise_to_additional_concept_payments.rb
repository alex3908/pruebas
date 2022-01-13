# frozen_string_literal: true

class AddEnterpriseToAdditionalConceptPayments < ActiveRecord::Migration[5.2]
  def change
    add_reference :additional_concept_payments, :enterprise, foreign_key: true
  end
end
