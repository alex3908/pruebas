class CreateAutomatedEmailUserConcepts < ActiveRecord::Migration[5.2]
  def change
    create_table :automated_email_user_concepts do |t|
      t.references :automated_email, index: true, null: true, foreign_key: true
      t.references :folder_user_concept, index: true, null: true, foreign_key: true
      t.timestamps
    end
  end
end
