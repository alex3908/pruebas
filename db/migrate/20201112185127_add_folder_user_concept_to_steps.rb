# frozen_string_literal: true

class AddFolderUserConceptToSteps < ActiveRecord::Migration[5.2]
  def change
    add_reference :steps, :folder_user_concept, foreign_key: true
  end
end
