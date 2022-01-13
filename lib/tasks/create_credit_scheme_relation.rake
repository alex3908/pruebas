# frozen_string_literal: true

namespace :create_credit_scheme_relation do
  desc "Create credit scheme relation"

  task run: :environment do
    credit_scheme = CreditScheme.create(name: "15 años", status: true)
    Period.create(payments: 60, interest: 0, order: 1, credit_scheme: credit_scheme)
    Period.create(payments: 60, interest: 1, order: 2, credit_scheme: credit_scheme)
    Period.create(payments: 60, interest: 1.25, order: 3, credit_scheme: credit_scheme)
    Discount.create(name: "Contado", discount: 0, total_payments: 1, credit_scheme: credit_scheme)
    DownPayment.create(term: 1, min: 10, credit_scheme: credit_scheme)

    Stage.all.each do |stage|
      stage.update(credit_scheme: credit_scheme)
    end

    Folder.all.each do |folder|
      folder.payment_scheme.update(credit_scheme: credit_scheme)
    end
  end
end
