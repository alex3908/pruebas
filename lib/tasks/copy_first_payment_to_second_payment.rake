# frozen_string_literal: true

namespace :copy_first_payment_to_second_payment do
  desc "add phone code to clients"

  task run: :environment do
    PaymentScheme.all.each do |payment_scheme|
      payment_scheme.update(second_payment: payment_scheme.first_payment)
    end

    CreditScheme.all.each do |credit_scheme|
      credit_scheme.update(second_payment: credit_scheme.first_payment)
    end
  end
end
  