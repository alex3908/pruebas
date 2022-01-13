# frozen_string_literal: true

module DiscountsHelper
  def get_relative_plan(total_payments, lot)
    if lot.stage.credit_scheme.relative_discount
      today = Time.zone.now
      expired_months = (today.year * 12 + today.month) - (lot.stage.release_date.year * 12 + lot.stage.release_date.month)

      relative_payments = total_payments + expired_months
      relative_plan = Discount.where("total_payments <= (?) AND is_active = (?) AND credit_scheme_id = (?)", relative_payments, true, lot.stage.credit_scheme_id).order(total_payments: :desc).first
      { discount: relative_plan.discount }
    else
      relative_plan = Discount.where("total_payments <= (?) AND is_active = (?) AND credit_scheme_id = (?)", total_payments, true, lot.stage.credit_scheme_id).order(total_payments: :desc).first
      { discount: relative_plan.discount }
    end
  end
end
