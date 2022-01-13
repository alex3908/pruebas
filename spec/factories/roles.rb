# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    factory :salesman_role do
      key { "salesman" }
      is_evo { true }
      name { "Asesor" }
      initialize_with { Role.find_or_create_by(key: key) }
    end

    factory :superadmin_role do
      key { "superadmin" }
      is_evo { false }
      name { "Super Admin" }
      initialize_with { Role.find_or_create_by(key: key) }
    end
  end
end
