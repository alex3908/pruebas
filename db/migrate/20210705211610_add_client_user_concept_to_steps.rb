# frozen_string_literal: true

class AddClientUserConceptToSteps < ActiveRecord::Migration[5.2]
  def change
    add_reference :steps, :client_user_concept, foreign_key: true
  end
end
