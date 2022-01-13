# frozen_string_literal: true

module PurchaseConditionsConcern
  extend ActiveSupport::Concern

  def purchase_conditions_formatted(opening_commission: 0, purchase_conditions:, phase_date:, stage_date:)
    return nil if purchase_conditions.nil?

    Liquid::Template.parse(purchase_conditions).render!({
      "comision_apertura_activa" => opening_commission > 0,
      "comision_apertura" => opening_commission,
      "nivel_2_fecha" => stage_date,
      "nivel_1_fecha" => phase_date
      }, { strict_variables: true }, filters: [LiquidFilters])
  end
end
