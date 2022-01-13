# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { "Usuario" }
    sequence :last_name do |n|
      "Prueba ##{n}"
    end
    email { Faker::Internet.email }
    password { "adminadmin" }
    password_confirmation { "adminadmin" }
    branch factory: :main_branch
    role factory: :superadmin_role

    # factory :director_user do
    #   role factory: :director_role
    #   structure factory: :structure, role: :director_role, parent:
    # end
    # factory :salesman_user do
    #   role factory: :salesman_role
    #   structure factory: :salesman_structure, role: :salesman_role, parent:
    #   branch
    # end
  end
end
