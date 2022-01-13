# frozen_string_literal: true

FactoryBot.define do
  factory  :credit_scheme do
    name { "15 años" }
    status { true }
    quotation_type { CreditScheme.quotation_types[:multiple_periods] }
  end
end
