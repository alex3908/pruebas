# frozen_string_literal: true

class CreateClassifiersUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :classifiers_users do |t|
      t.references :user, foreign_key: true
      t.references :classifier, foreign_key: true
    end
  end
end
