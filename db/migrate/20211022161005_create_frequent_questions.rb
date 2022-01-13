# frozen_string_literal: true

class CreateFrequentQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :frequent_questions do |t|
      t.text :title
      t.text :content
      t.string :link
      t.integer :status, default: 0
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
