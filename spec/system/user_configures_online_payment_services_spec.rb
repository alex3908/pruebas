# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UserConfiguresOnlinePaymentServices", type: :system do
  before(:each) do
    read_enterprise = Permission.create!(subject_class: "Enterprise", action: "read")
    update_enterprise = Permission.create!(subject_class: "Enterprise", action: "update")
    create_online_payment_service = Permission.create!(subject_class: "OnlinePaymentService", action: "create")
    update_online_payment_service = Permission.create!(subject_class: "OnlinePaymentService", action: "update")

    RolePermission.create(role: create(:superadmin_role), permission: read_enterprise)
    RolePermission.create(role: create(:superadmin_role), permission: update_enterprise)
    RolePermission.create(role: create(:superadmin_role), permission: create_online_payment_service)
    RolePermission.create(role: create(:superadmin_role), permission: update_online_payment_service)
    PaymentMethod.create(name: "Transferencia")
  end
  # it "lets the user create payment service with Netpay", js: true do
  # User: hctrbjujhzuyaffhcw@upived.online
  # Password: hctrbjujhzuyaffhcwA.1"
  # Url: https://manager-cert-term.netpaydev.com

  #  login_as create(:user)
  #  visit edit_enterprise_path(create(:enterprise))
  #  select "Netpay", from: "online_payment_service_provider", visible: true
  #  click_on "Crear de pago online", visible: false
  #  first("input[name='online_payment_service[environment]']+div.toggle", visible: false).click

  #  fill_in "Llave privada (charge)", with: "sk_netpay_lyUUHORZlTDZHxbVAASSdXeCyxSOtuuSIcaDscGQhixMH", visible: false
  #  fill_in "Llave pública (charge)", with: "pk_netpay_zPNEgtqalPiKnlYcjhBoZUihv", visible: false
  #  fill_in "Llave privada (loop)", with: "sk_netpay_mmbPcZUDQoQCtvMMELXGLQnwjgkKVRteIvKvkmtSAdksp", visible: false
  #  fill_in "Llave pública (loop)", with: "pk_netpay_TspojaWplnGFwEPlbqunGLEak", visible: false

  #  first("#online_payment_service_bank_account_id option", visible: false).select_option
  #  first("#online_payment_service_payment_method_id option", visible: false).select_option
  #  click_on "Guardar"


  #  expect(page).to have_content("El servicio fue inicializado correctamente, asegúrate de completar la configuración para que pueda ser usado")

  #  expect(page).to have_selector("input[id='online_payment_service_properties_charge_secret_key']", visible: false)
  #  expect(find_field(id: "online_payment_service_properties_charge_secret_key", visible: false).value).to eq("sk_netpay_lyUUHORZlTDZHxbVAASSdXeCyxSOtuuSIcaDscGQhixMH")
  #  expect(page).to have_selector("input[id='online_payment_service_properties_charge_public_key']", visible: false)
  #  expect(find_field(id: "online_payment_service_properties_charge_public_key", visible: false).value).to eq("pk_netpay_zPNEgtqalPiKnlYcjhBoZUihv")

  #  expect(page).to have_selector("input[id='online_payment_service_properties_loop_secret_key']", visible: false)
  #  expect(find_field(id: "online_payment_service_properties_loop_secret_key", visible: false).value).to eq("sk_netpay_mmbPcZUDQoQCtvMMELXGLQnwjgkKVRteIvKvkmtSAdksp")
  #  expect(page).to have_selector("input[id='online_payment_service_properties_loop_public_key']", visible: false)
  #  expect(find_field(id: "online_payment_service_properties_loop_public_key", visible: false).value).to eq("pk_netpay_TspojaWplnGFwEPlbqunGLEak")
  # end
end
