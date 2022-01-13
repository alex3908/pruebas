# frozen_string_literal: true

FactoryBot.define do
  factory :bank_account do
    holder { "Empresa Demo" }
    bank { "HSBC" }
    account_number { "01600326941" }
    currency { "MXN" }
    clabe { "002115016003269411" }
  end
end
