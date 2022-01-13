# frozen_string_literal: true

namespace :set_quotation_type do
  desc "Assigns quotation type to credit schemes"

  task assign: :environment do
    CreditScheme.where(quotation_type: nil).each do |credit_scheme|
      if credit_scheme.compound_interest
        credit_scheme.update(quotation_type: CreditScheme.quotation_types[:multiple_periods])
      else
        credit_scheme.update(quotation_type: CreditScheme.quotation_types[:one_period])
      end
    end
  end
end
