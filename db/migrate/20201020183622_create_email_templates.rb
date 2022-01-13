# frozen_string_literal: true

class CreateEmailTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :email_templates do |t|
      t.string :name
      t.string :title
      t.string :subject
      t.text :html

      t.timestamps
    end
  end
end
