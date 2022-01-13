# frozen_string_literal: true

class AddRelatedWithToTags < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :related_to, :string, default: "contracts"
  end
end
