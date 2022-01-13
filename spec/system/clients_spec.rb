# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Clients", type: :system do
  before(:all) do
    Capybara.default_max_wait_time = 10
  end

  it "lets the user create a client of the type physical personal", js: true do
    login_as admin_user
    visit clients_path
    click_link("Nuevo Cliente")

    fill_in "Nombre", with: Faker::Name.first_name, visible: true
    fill_in "Primer Apellido", with: Faker::Name.last_name, visible: true
    fill_in "Segundo Apellido", with: Faker::Name.last_name, visible: true
    fill_in "Correo", with: Faker::Internet.email, visible: true
    fill_in "Teléfono Principal", with: "9999999999"
    fill_in "Teléfono Opcional", with: "9999999999"
    select "Masculino", from: "Género"
    select "Persona Física", from: "Tipo"
    attach_file("client[official_identification]", example_pdf, visible: false)
    attach_file("client[address_proof]", example_pdf, visible: false)
    attach_file("client[fiscal_act]", example_pdf, visible: false)
    attach_file("client[curp]", example_pdf, visible: false)
    attach_file("client[birth_certificate]", example_pdf, visible: false)

    first("#accordion-additional div", visible: true).click

    fill_in "client[additional][curp]", with: "XEXX010101HNEXXXA4", visible: true
    fill_in "RFC", with: "XAXX010101000", visible: true

    # Click the sweetalert buttons.
    first(".swal2-actions .swal2-confirm", visible: true).click
    first(".swal2-actions .swal2-confirm", visible: true).click

    fill_in "Lugar de Nacimiento", with: Faker::Address.state, visible: true
    fill_in "Ocupación", with: Faker::Company.profession, visible: true
    find("#client_additional_nationality > option:nth-child(2)").select_option
    find("#client_additional_civil_status > option:nth-child(2)").select_option
    find("#client_additional_identification_type_id > option:nth-child(2)").select_option
    fill_in "Número de Identificación", with: Faker::IDNumber.valid, visible: true
    fill_in "Vigencia de Identificación", with: random_date, visible: true
    fill_in "Fecha de Nacimiento", with: random_date, visible: true

    find("#client_additional_country > option:nth-child(2)").select_option
    fill_in "Código Postal", with: Faker::Address.postcode, visible: true
    fill_in "Estado", with: Faker::Address.state, visible: true
    fill_in "Ciudad", with: Faker::Address.city, visible: true
    fill_in "Colonia", with: Faker::Address.community, visible: true
    fill_in "Calle", with: Faker::Address.street_name, visible: true
    fill_in "Localidad", with: Faker::Address.city, visible: true
    fill_in "Número exterior", with: Faker::Address.building_number, visible: true
    fill_in "Número interior", with: Faker::Address.building_number, visible: true

    click_on "Guardar"
    expect(page).to have_content("Cliente creado correctamente.")
  end

  it "lets the user create a client of the type moral personal", js: true do
    login_as admin_user
    visit clients_path
    click_link("Nuevo Cliente")

    select "Persona Moral", from: "Tipo"
    fill_in "Nombre del comercio o empresa", with: Faker::Company.name, visible: true
    fill_in "Correo", with: Faker::Internet.email, visible: true
    fill_in "Teléfono Principal", with: "9999999999"
    fill_in "Teléfono Opcional", with: "9999999999"
    select "Masculino", from: "Género"

    attach_file("client[constitutional_act]", example_pdf, visible: false)
    attach_file("client[fiscal_act]", example_pdf, visible: false)

    first("#accordion-additional div", visible: true).click

    fill_in "client[additional][curp]", with: "XEXX010101HNEXXXA4", visible: true
    fill_in "client[additional][legal_rfc]", with: "XAXX010101000", visible: true
    fill_in "client[additional][rfc_company]", with: "XAXX010101000", visible: true

    fill_in "Nombre", with: Faker::Name.first_name, visible: true
    find("#client_additional_identification_type_id > option:nth-child(2)").select_option
    fill_in "Número de Identificación", with: Faker::IDNumber.valid, visible: true
    fill_in "Vigencia de Identificación", with: random_date, visible: true
    fill_in "Fecha de Nacimiento", with: random_date, visible: true
    find("#client_additional_country_nationality > option:nth-child(2)").select_option

    # Click the sweetalert buttons.
    first(".swal2-actions .swal2-confirm", visible: true).click
    first(".swal2-actions .swal2-confirm", visible: true).click
    first(".swal2-actions .swal2-confirm", visible: true).click

    fill_in "Nombre", with:  Faker::Company.name, visible: true

    fill_in "Actividad o Giro", with: Faker::Company.industry, visible: true
    find("#client_additional_company_identification_type_id > option:nth-child(2)").select_option

    fill_in "Número de Identificación de la empresa", with: Faker::IDNumber.valid, visible: true
    fill_in "Vigencia de Identificación de la empresa", with: random_date, visible: true

    fill_in "Nombre del Notario Público", with: Faker::Name.first_name, visible: true
    fill_in "Número del Notario Público", with: Faker::IDNumber.valid, visible: true
    fill_in "Estado del Registro Público de la Propiedad y Comercio", with: Faker::Address, visible: true
    fill_in "Fecha del Registro Público de la Propiedad y Comercio", with: random_date, visible: true
    fill_in "Fecha de constitución", with: random_date, visible: true
    fill_in "Número de Folio Electrónico Mercantil", with: Faker::IDNumber.valid, visible: true

    find("#client_additional_country > option:nth-child(2)").select_option
    fill_in "Código Postal", with: Faker::Address.postcode, visible: true
    fill_in "Calle", with: Faker::Address.street_name, visible: true
    fill_in "Localidad", with: Faker::Address.city, visible: true
    fill_in "Número exterior", with: Faker::Address.building_number, visible: true
    fill_in "Número interior", with: Faker::Address.building_number, visible: true

    click_on "Guardar"
    expect(page).to have_content("Cliente creado correctamente.")
  end

  def admin_user
    User.find_by(role: Role.find_by(key: "superadmin"))
  end

  def example_pdf
    Rails.root.join("spec/fixtures/files/testing-rails.pdf")
  end

  def random_date
    Faker::Date.in_date_period.strftime("%d/%m/%Y")
  end
end
