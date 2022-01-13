# frozen_string_literal: true

FactoryBot.define do
  factory :payment_reference do
    reference { "MyString" }
    folder_id { "" }
    response { "" }
  end
end
