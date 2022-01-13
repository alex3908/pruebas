# frozen_string_literal: true

FactoryBot.define do
  factory :branch do
    sequence :name do |n|
      "Empresa ##{n}"
    end
    address { "" }
    phone { "" }

    factory :main_branch do
      name { "Matriz" }
    end
  end
end
