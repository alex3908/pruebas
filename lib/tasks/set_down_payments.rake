# frozen_string_literal: true

namespace :set_down_payments do
  desc "Run set_down_payments task"

  task run: :environment do
    CreditScheme.all.each do |credit_scheme|
      if credit_scheme.down_payments.empty?
        credit_scheme.down_payments.create!(term: 1, min: credit_scheme.min_down_payment)
      end
    end
  end
end
