# frozen_string_literal: true

module PaymentPayActionsConcern
  extend ActiveSupport::Concern

  def add_restructure(restructure_type, down_payment_count, payments_count, new_day, current_discount, grace_months, delay_months)
    term = Restructure.down_payment_concept?(restructure_type) ? down_payment_count : payments_count
    self.restructure_attributes = {
        concept: restructure_type,
        current_term: term,
        current_day: new_day,
        current_discount: current_discount,
        grace_months: grace_months,
        delay_months: delay_months,
        without_promotions: Restructure.restructure_concept?(restructure_type)
    }
  end
end
