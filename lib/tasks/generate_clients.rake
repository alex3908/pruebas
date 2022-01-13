# frozen_string_literal: true

namespace :generate_clients do
  desc "Generates 100 clients"
  task run: :environment do
    branch = Branch.first

    director = Role.find_by(level: 0).users.first
    vice_director = Role.find_by(level: 1).users.first
    manager = Role.find_by(level: 2).users.first
    coordinator = Role.find_by(level: 3).users.first
    realtor = Role.find_by(level: 5).users.first
    salesman = Role.find_by(level: 4).users.first

    sales_executives = [director, vice_director, manager, coordinator, realtor, salesman]

    current = Timecop.freeze(Date.today - 400)

    100.times do
      Current.user = sales_executives.sample
      gender = Faker::Gender.binary_type.downcase

      Client.create(
        name: (gender == "female") ? Faker::Name.female_first_name : Faker::Name.male_first_name,
        first_surname: Faker::Name.last_name,
        second_surname: Faker::Name.last_name,
        main_phone: Faker::PhoneNumber.cell_phone_in_e164[-10..-1],
        optional_phone: Faker::PhoneNumber.cell_phone_in_e164[-10..-1],
        email: Faker::Internet.email,
        person: "physical",
        gender: gender,
        branch: branch.name,
        user: Current.user
      )

      current = Timecop.freeze(Date.today + 4)
    end
    Timecop.return
  end
end
