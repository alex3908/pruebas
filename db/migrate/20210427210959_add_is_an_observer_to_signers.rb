# frozen_string_literal: true

class AddIsAnObserverToSigners < ActiveRecord::Migration[5.2]
  def change
    add_column :signers, :is_an_observer, :boolean, default: false
  end
end
