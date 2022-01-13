# frozen_string_literal: true

class SalesController < ApplicationController
  authorize_resource class: false

  def index
    @commissions = get_commissions_count if can?(:read, Commission)

    @referrer = current_user.referrer.count if can?(:read, :referent)

    @structures = get_structures_count if can?(:read, Structure)
  end

  private

    def get_commissions_count
      return Commission.joins(:folder_user).where(folder_users: { user: current_user }).count if can?(:reserve, :quote)
      Commission.count
    end

    def get_structures_count
      return current_user.structure.descendant_ids.size if current_user.has_structure?
      Structure.count
    end
end
