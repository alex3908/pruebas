# frozen_string_literal: true

class CreateClassifierUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :classifier_users do |t|
      t.references :classifier, index: true, foreign_key: true
      t.integer :user_id
      t.timestamps
    end
  end
end
