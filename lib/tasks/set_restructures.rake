# frozen_string_literal: true

namespace :set_restructures do
  desc "Run set_restructures task"

  task run: :environment do
    Payment.where.not(concept: nil).each do |payment|
      restructure = Restructure.new
      restructure.payment = payment
      restructure.concept = payment.concept
      restructure.current_term = payment.current_term
      restructure.current_discount = payment.current_discount
      restructure.save
    end
  end
end
  