# frozen_string_literal: true

branch = Branch.create!(name: "Matriz", address: "", phone: "")
UserClient.create!(email: "default@adaracrm.mx", password: "adminadmin")
IdentificationType.create_with(display_as: "Credencial para votar", institution: "Instituto Nacional Electoral").find_or_create_by(name: "INE")
IdentificationType.create_with(display_as: "Credencial para votar", institution: "Instituto Federal Electoral").find_or_create_by(name: "IFE")
IdentificationType.create_with(display_as: "Cédula Profesional", institution: "Secretaría de Educación Pública").find_or_create_by(name: "Cédula Profesional")
IdentificationType.create_with(display_as: "Pasaporte", institution: "Secretaría de Relaciones Exteriores").find_or_create_by(name: "Pasaporte")

enterprise = Enterprise.create!(
  business_name: "Empresa Demo",
  short_business_name: "Empresa Demo",
  rfc: "XAXX010101000",
  state: "Yucatan",
  location: "M\u00E9rida",
  street: "Calle 29",
  outdoor_number: "462",
  indoor_number: "",
  colony: "Gonzalo Guerrero",
)

BankAccount.create!(
  holder: "Empresa Demo",
  bank: "HSBC",
  account_number: "01600326941",
  currency: "MXN",
  clabe: "002115016003269411",
  payable_type: "Enterprise",
  payable_id: enterprise.id
)

PaymentMethod.create!(name: "Efectivo")

projects = Project.create!([
  { name: "15 años", active: true, currency: "MXN", email: "contacto@demo.com", phone: "9999999999", quotation: "new", slug: "15-anios" },
  { name: "Convencional", active: true, currency: "MXN", email: "contacto@demo.com", phone: "9999999999", quotation: "conventional", slug: "convencional" }
])

phases = Phase.create!([
  { name: "Fase 1", start_date: Time.local(2020, 1, 1), project: projects.first },
  { name: "Fase 1", start_date: Time.local(2020, 1, 1), project: projects.last }
])

credit_scheme = CreditScheme.create(name: "15 años", status: true, quotation_type: CreditScheme.quotation_types[:multiple_periods])
Period.create(payments: 60, interest: 0, order: 1, credit_scheme: credit_scheme)
Period.create(payments: 60, interest: 1, order: 2, credit_scheme: credit_scheme)
Period.create(payments: 60, interest: 1.25, order: 3, credit_scheme: credit_scheme)
Discount.create(name: "Contado", discount: 0, total_payments: 1, credit_scheme: credit_scheme)
DownPayment.create(term: 1, min: 10, credit_scheme: credit_scheme)

simple_scheme = CreditScheme.create(name: "36 meses", status: true)
Period.create(payments: 36, interest: 0, order: 1, credit_scheme: simple_scheme)
Discount.create(name: "Contado", discount: 0, total_payments: 1, credit_scheme: simple_scheme)
DownPayment.create(term: 1, min: 10, credit_scheme: simple_scheme)

initial_commission_scheme = CommissionScheme.create(name: "Global", global_commission: 0)

stages = Stage.create!([
  { name: "Etapa 1", price: 210, active: true, release_date: Time.local(2020, 1, 1), phase: phases.first, enterprise: enterprise, stage_type: "residential", order: 1, credit_scheme: credit_scheme, commission_scheme: initial_commission_scheme, initial_payment_expiration: 5 },
  { name: "Etapa 1", price: 210, active: true, release_date: Time.local(2020, 1, 1), phase: phases.last, enterprise: enterprise, stage_type: "residential", order: 1, credit_scheme: simple_scheme, commission_scheme: initial_commission_scheme, initial_payment_expiration: 5 },
])

Lot.create!([
  { number: 1, depth: 30.557, front: 12.154, area: 365.187, price: 0, stage: stages.first },
  { number: 2, depth: 30.557, front: 12.154, area: 365.187, price: 0, stage: stages.first },
  { number: 3, depth: 32.373, front: 12.000, area: 390.840, price: 0, stage: stages.first },
  { number: 4, depth: 32.373, front: 12.000, area: 390.840, price: 0, stage: stages.first },
  { number: 5, depth: 31.964, front: 16.435, area: 557.617, price: 10, stage: stages.first },
  { number: 1, depth: 30.557, front: 12.154, area: 365.187, price: 0, stage: stages.last },
  { number: 2, depth: 30.557, front: 12.154, area: 365.187, price: 0, stage: stages.last },
  { number: 3, depth: 32.373, front: 12.000, area: 390.840, price: 0, stage: stages.last },
  { number: 4, depth: 32.373, front: 12.000, area: 390.840, price: 0, stage: stages.last },
  { number: 5, depth: 31.964, front: 16.435, area: 557.617, price: 10, stage: stages.last },
])


[
  "settings",
  "permissions",
  "roles_permissions",
  "descriptions",
  "evaluations",
].each do |seed|
  file = Rails.root.join("db", "seeds", "#{seed}.rb")
  load(file) if File.exist?(file)
end

super_admin_role = Role.where(key: "superadmin", is_evo: false).first_or_create!(name: "Super Admin")
director_role = Role.where(key: "director", is_evo: true, level: 0).first_or_create!(name: "Director")
vice_director_role = Role.where(key: "vice_director", is_evo: true, level: 1).first_or_create!(name: "Subdirector")
manager_role = Role.where(key: "manager", is_evo: true, level: 2).first_or_create!(name: "Gerente")
coordinator_role = Role.where(key: "coordinator", is_evo: true, level: 3).first_or_create!(name: "Coordinador")
realtor_role = Role.where(key: "realtor", is_evo: true, level: 5).first_or_create!(name: "Inmobiliaria")
salesman_role = Role.where(key: "salesman", is_evo: true, level: 4).first_or_create!(name: "Asesor")

bank_attrs = {
  holder: "Staff",
  bank: "HSBC",
  account_number: "01600326941",
  currency: "MXN",
  clabe: "002115016003269411",
  payable_type: "User"
}

# rubocop:disable Lint/UselessAssignment
superadmin_user = User.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name + " " + Faker::Name.last_name, email: "superadmin@adaracrm.mx", role: super_admin_role, password: "adminadmin", password_confirmation: "adminadmin", branch: branch, phone: Faker::PhoneNumber.cell_phone_in_e164[-10..-1])
superadmin_user.bank_accounts.create!(bank_attrs.merge(payable_id: superadmin_user.id))

director_user = User.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name + " " + Faker::Name.last_name, email: Faker::Internet.email, role: director_role, password: "adminadmin", password_confirmation: "adminadmin", branch: branch, phone: Faker::PhoneNumber.cell_phone_in_e164[-10..-1])
director_user.bank_accounts.create!(bank_attrs.merge(payable_id: director_user.id))

vice_director_user = User.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name + " " + Faker::Name.last_name, email: Faker::Internet.email, role: vice_director_role, password: "adminadmin", password_confirmation: "adminadmin", branch: branch, phone: Faker::PhoneNumber.cell_phone_in_e164[-10..-1])
vice_director_user.bank_accounts.create!(bank_attrs.merge(payable_id: vice_director_user.id))

manager_user = User.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name + " " + Faker::Name.last_name, email: Faker::Internet.email, role: manager_role, password: "adminadmin", password_confirmation: "adminadmin", branch: branch, phone: Faker::PhoneNumber.cell_phone_in_e164[-10..-1])
manager_user.bank_accounts.create!(bank_attrs.merge(payable_id: manager_user.id))

coordinator_user = User.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name + " " + Faker::Name.last_name, email: Faker::Internet.email, role: coordinator_role, password: "adminadmin", password_confirmation: "adminadmin", branch: branch, phone: Faker::PhoneNumber.cell_phone_in_e164[-10..-1])
coordinator_user.bank_accounts.create!(bank_attrs.merge(payable_id: coordinator_user.id))

relator_user = User.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name + " " + Faker::Name.last_name, email: Faker::Internet.email, role: realtor_role, password: "adminadmin", password_confirmation: "adminadmin", branch: branch, phone: Faker::PhoneNumber.cell_phone_in_e164[-10..-1])
relator_user.bank_accounts.create!(bank_attrs.merge(payable_id: relator_user.id))

salesman_user = User.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name + " " + Faker::Name.last_name, email: Faker::Internet.email, role: salesman_role, password: "adminadmin", password_confirmation: "adminadmin", branch: branch, phone: Faker::PhoneNumber.cell_phone_in_e164[-10..-1])
salesman_user.bank_accounts.create!(bank_attrs.merge(payable_id: salesman_user.id))

# rubocop:enable Lint/UselessAssignment

salesman_user.projects << projects.first
salesman_user.projects << projects.last
salesman_user.stages << stages.first
salesman_user.stages << stages.last

salesman_user.save!



# rubocop:disable Lint/UselessAssignment
director_tree = Structure.create!(user: director_user, role: director_role, active: true)
vice_director_tree = Structure.create!(user: vice_director_user, role: vice_director_role, active: true, parent: director_tree)
manager_tree = Structure.create!(user: manager_user, role: manager_role, active: true, parent: vice_director_tree)
coordinator_tree = Structure.create!(user: coordinator_user, role: coordinator_role, active: true, parent: manager_tree)
salesman_tree = Structure.create!(user: salesman_user, role: salesman_role, active: true, parent: coordinator_tree)
# rubocop:enable Lint/UselessAssignment

pipeline_file = Rails.root.join("db", "seeds", "pipeline.rb")
load(pipeline_file) if File.exist?(pipeline_file)

ClientUserConcept.create_with(name: "Ejecutivo de ventas", max_users: 1).find_or_create_by(key: :sales_executive)

FolderUser.concepts.keys.map { |key| FolderUserConcept.find_or_create_by(name: I18n.t("activerecord.attributes.folder_user.concepts.#{key}"), key: key) }

Current.user = salesman_user

10.times do
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
    branch: branch.name
  )
end

10.times do |count|
  puts count

  lot = Lot.create({ number: 100 + count, depth: 30.557, front: 12.154, area: 365.187, price: 0, stage: stages.first })

  gender = Faker::Gender.binary_type.downcase
  client = Client.create(
    name: (gender == "female") ? Faker::Name.female_first_name : Faker::Name.male_first_name,
    first_surname: Faker::Name.last_name,
    second_surname: Faker::Name.last_name,
    main_phone: Faker::PhoneNumber.cell_phone_in_e164[-10..-1],
    optional_phone: Faker::PhoneNumber.cell_phone_in_e164[-10..-1],
    email: Faker::Internet.email,
    person: "physical",
    gender: gender,
    branch: branch.name
  )

  moment = Time.at(Time.local(2020, 1, 1) + rand * (Time.now.to_f - Time.local(2020, 1, 1).to_f))
  Timecop.freeze(moment)

  folder = Folder.create({
    lot: lot,
    client: client,
    user: client.sales_executive,
    status: "active",
    buyer: "owner",
    start_date: moment,
    ready: false,
    step: Step.first_step,
    reminders_enabled: true,
    total_sale: lot.area * lot.price_with_additional,
    payment_scheme_attributes: {
      name: "180 meses",
      initial_payment: "5000.0",
      discount: "0.0",
      total_payments: 180,
      down_payment_finance: 1,
      down_payment: "2668.927",
      buy_price: lot.price_with_additional,
      first_payment: 8,
      lock_payment: "5000.0",
      credit_scheme: stages.first.credit_scheme,
      is_commissionable: true,
      max_commission_amount: 0 }
  })

  numb = rand(4)

  new_time = moment

  if numb >= 1
    new_time = new_time + rand(1..28).days
    Timecop.travel(new_time)
    folder.approve
  end

  if numb >= 2
    new_time = new_time + rand(1..28).days
    Timecop.travel(new_time)
    folder.approve
  end

  if numb >= 3
    new_time = new_time + rand(1..28).days
    Timecop.travel(new_time)
    folder.approve
  end

  Timecop.return
end
