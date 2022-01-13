# frozen_string_literal: true

class AddCommissionSchemeToStage < ActiveRecord::Migration[5.2]
  def change
    add_reference :stages, :commission_scheme, foreign_key: true, after: :active_commissions
  end
end
