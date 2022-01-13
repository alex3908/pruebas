# frozen_string_literal: true

FactoryBot.define do
  factory :identification_type do
    name { "IFE" }
    institution { "Instituto Nacional Electoral" }
    display_as { "Credencial para Votar" }
  end
end
