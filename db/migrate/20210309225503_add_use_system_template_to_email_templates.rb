# frozen_string_literal: true

class AddUseSystemTemplateToEmailTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :email_templates, :use_system_template, :boolean, default: false
  end
end
