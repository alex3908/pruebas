# frozen_string_literal: true

class RemoveNameFromEmailTemplates < ActiveRecord::Migration[5.2]
  def change
    remove_column :email_templates, :name, :string
  end
end
