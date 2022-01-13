# frozen_string_literal: true

class AddRelativeDiscountToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :relative_discount, :boolean, default: true
  end
end
