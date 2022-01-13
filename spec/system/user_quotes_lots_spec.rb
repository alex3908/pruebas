# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UserQuotesLots", type: :system do
  before(:all) do
    Capybara.default_max_wait_time = 10
  end

  # it "lets the user quote a lot and reserve it", js: true do
  #  login_as salesman_user
  #  visit clients_path

  #  first_client_row = find("tbody tr", match: :first)

  #  within(first_client_row) do
  #    find("span a", match: :first).click
  #  end

  #  find('[data-original-title="15 años"]').click
  #  click_link("Privadas")
  #  click_on("Opciones")
  #  click_on("Venta")
  #  click_on("Venta", match: :first)
  #  click_on("Reservar")
  #  click_button("Continuar")

  #  expect(page).to have_content("Activo")
  # end

  # it "allows salesman to have multiple reserves on lots", js: true do
  #  login_as salesman_user
  #  visit clients_path

  #  first_client_row = find("tbody tr", match: :first)

  #  within(first_client_row) do
  #    find("span a", match: :first).click
  #  end

  #  find('[data-original-title="15 años"]').click
  #  click_link("Privadas")
  #  click_on("Opciones")
  #  click_on("Venta")
  #  expect(page).to have_content("Cotizar")
  #  lots_rows = all(:css, "tbody tr")
  #  within(lots_rows[4]) do
  #    click_on("Venta")
  #  end

  #  expect(page).to have_content("Reservar")
  # end

  def salesman_user
    user_by_role("salesman")
  end

  def role(key)
    Role.where(key: key, is_evo: true).take
  end

  def user_by_role(key)
    User.find_by(role: role(key))
  end
end
