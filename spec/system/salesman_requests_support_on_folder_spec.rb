# frozen_string_literal: true

require "rails_helper"

RSpec.describe "SalesmanRequestsSupportOnFolder", type: :system do
  let(:project) { Project.find(1) }
  let(:phase) { Phase.find(1) }
  let(:stage) { Stage.find(1) }
  let(:lot) { Lot.find(1) }
  let(:client) { salesman_user.client.first }
  let(:branch) { Branch.create(name: "Other", address: "", phone: "") }

  before(:all) do
    Project.find(1).project_users.create(user: salesman_user)
    Stage.find(1).stage_users.create(user: salesman_user)
  end

  # it "doesn't allow submitting form when no request manager is assigned", js: true do
  #   folder = create_folder
  #   salesman_user.structure.parent.parent.update(user: nil)

  #   visit folder_path(id: folder.id)
  #   click_button("Acciones")
  #   click_on("Solicitar soporte")

  #   expect(page).not_to have_button("Enviar")
  #   expect(page).to have_content("No tienes un gerente asignado")
  # end

  # it "successfully creates new SupportSale", js: true do
  #   folder = create_folder
  #   support_vicedirector = create_support_vicedirector
  #   visit folder_path(id: folder.id)
  #   click_button("Acciones")
  #   click_on("Solicitar soporte")
  #   select support_vicedirector.label, from: "support_sale_support_vicedirector_id"
  #   click_on("Enviar")
  #   click_on("Ver solicitud")

  #   vicedirector_percentages = folder.folder_users.where(role: role("vice_director")).map(&:percentage)
  #   expect(vicedirector_percentages).to eq([0.25, 0.25])
  #   expect(page).to have_selector("input[value='#{folder.user.label}']")
  # end

  # it "replaces the label for support request in folder show view", js: true do
  #   folder = create_folder
  #   create_base_support_sale(folder)
  #   visit folder_path(folder)
  #   click_button("Acciones")

  #   expect(page).to have_content("Ver solicitud de soporte")
  # end

  describe "after requested" do
    # it "allows manager to cancel the request", js: true do
    #   support_sale = create_support_sale
    #   folder = support_sale.folder

    #   login_as support_sale.request_manager
    #   visit support_sale_folder_path(folder.id)
    #   click_on("Cancelar")
    #   click_on("Confirmar")

    #   visit folder_path(folder)
    #   expect(page).not_to have_content("Ver solicitud de soporte")
    # end

    # it "allows request manager to assign a support manager", js: true do
    #   support_sale = create_support_sale

    #   assign_support_manager(support_sale)

    #   support_manager = support_sale.reload.support_manager
    #   folder_user_request_manager = support_sale.folder.folder_users.where(user: support_sale.request_manager).take
    #   folder_user_support_manager = support_sale.folder.folder_users.where(user: support_manager).take

    #   expect(support_sale.support_manager).not_to be_nil
    #   expect(folder_user_request_manager.percentage.to_f).to eq(0.25)
    #   expect(folder_user_support_manager.percentage.to_f).to eq(0.25)
    #   expect(page).to have_content("La solicitud fue actualizada correctamente.")
    # end

    # it "allows support manager to choose a support coordinator", js: true do
    #   support_sale = create_support_sale
    #   assign_support_manager(support_sale)

    #   assign_support_coordinator(support_sale.reload)

    #   support_coordinator = support_sale.reload.support_coordinator
    #   folder_user_request_coordinator = support_sale.folder.folder_users.where(user: support_sale.request_coordinator).take
    #   folder_user_support_coordinator = support_sale.folder.folder_users.where(user: support_coordinator).take

    #   expect(support_sale.support_coordinator).not_to be_nil
    #   expect(folder_user_request_coordinator.percentage.to_f).to eq(0.25)
    #   expect(folder_user_support_coordinator.percentage.to_f).to eq(0.25)
    #   expect(page).to have_content("La solicitud fue actualizada correctamente")
    # end

    # it "allows support manager to reject the request", js: true do
    #   support_sale = create_support_sale
    #   assign_support_manager(support_sale)

    #   login_as support_sale.reload.support_manager
    #   visit support_sale_folder_path(support_sale.folder.id)
    #   click_on("Rechazar")
    #   click_on("Confirmar")

    #   visit support_sale_folder_path(support_sale.folder.id)
    #   expect(page).to have_content("No tienes permisos para acceder a este sitio")
    # end

    # it "allows support coordinator to choose a supporter", js: true do
    #   support_sale = create_support_sale
    #   assign_support_manager(support_sale)
    #   assign_support_coordinator(support_sale.reload)
    #   assign_supporter(support_sale.reload)

    #   supporter = support_sale.reload.supporter
    #   folder_user_requester = support_sale.folder.folder_users.where(user: support_sale.requester).take
    #   folder_user_supporter = support_sale.folder.folder_users.where(user: supporter).take
    #   expect(support_sale.supporter).not_to be_nil
    #   expect(folder_user_requester.percentage.to_f).to eq(3.0)
    #   expect(folder_user_supporter.percentage.to_f).to eq(3.0)
    #   expect(support_sale.approved?).to be true
    #   expect(page).to have_content("La solicitud fue actualizada correctamente")
    # end


    def assign_support_manager(support_sale)
      create_support_manager(support_sale.support_vicedirector)
      login_as support_sale.request_manager
      visit support_sale_folder_path(support_sale.folder.id)
      select "Other Manager", from: "support_sale_support_manager_id"
      click_on("Actualizar")

      logout
    end

    def assign_support_coordinator(support_sale)
      create_support_coordinator(support_sale.support_manager)
      login_as support_sale.support_manager
      visit support_sale_folder_path(support_sale.folder.id)
      select "Support Coordinator", from: "support_sale_support_coordinator_id"
      click_on("Actualizar")

      logout
    end

    def assign_supporter(support_sale)
      create_supporter(support_sale.support_coordinator)
      login_as support_sale.reload.support_coordinator
      visit support_sale_folder_path(support_sale.folder.id)
      select "Supporter Salesman", from: "support_sale_supporter_id"
      click_on("Actualizar")
    end

    def create_support_sale
      folder = create_folder
      logout
      create_base_support_sale(folder, create_support_vicedirector)
    end


    def create_support_manager(vicedirector)
      manager = User.create!(
        first_name: "Other",
        last_name: "Manager",
        email: Faker::Internet.email,
        role: role("manager"),
        password: "test1234",
        password_confirmation: "test1234",
        branch: branch
      )
      Structure.create!(user: manager, role: role("manager"), active: true, parent: vicedirector.structure)

      manager
    end

    def create_support_coordinator(manager)
      coordinator = User.create!(
        first_name: "Support",
        last_name: "Coordinator",
        email: Faker::Internet.email,
        role: role("coordinator"),
        password: "test1234",
        password_confirmation: "test1234",
        branch: branch
      )
      Structure.create!(user: coordinator, role: role("coordinator"), active: true, parent: manager.structure)

      coordinator
    end

    def create_supporter(coordinator)
      supporter = User.create!(
        first_name: "Supporter",
        last_name: "Salesman",
        email: Faker::Internet.email,
        role: role("salesman"),
        password: "test1234",
        password_confirmation: "test1234",
        branch: branch
      )
      Structure.create!(user: supporter, role: role("salesman"), active: true, parent: coordinator.structure)

      supporter
    end
  end

  def create_support_vicedirector
    vicedirector = User.create!(
      first_name: "Other",
      last_name: "Vicedirector",
      email: Faker::Internet.email,
      role: role("vice_director"),
      password: "test1234",
      password_confirmation: "test1234",
      branch: branch
    )

    Structure.create!(user: vicedirector, role: role("vice_director"), active: true, parent: director_user.structure, max_branches: 5)

    vicedirector
  end

  def director_user
    user_by_role("director")
  end

  def vicedirector_user
    user_by_role("vice_director")
  end

  def salesman_user
    user_by_role("salesman")
  end

  def coordinator_user
    user_by_role("coordinator")
  end

  def manager_user
    user_by_role("manager")
  end

  def create_base_support_sale(folder, vicedirection = nil)
    SupportSale.create(folder: folder, requester: folder.user, support_vicedirector: vicedirection || vicedirector_user)
  end

  def create_folder
    login_as salesman_user
    visit quote_project_phase_stage_lot_path(project, phase, stage, lot, client: client)
    click_on("Reservar")
    click_on("Continuar")

    Folder.find_by(client: client, lot: lot, user: salesman_user)
  end


  def role(key)
    Role.where(key: key, is_evo: true).take
  end

  def user_by_role(key)
    User.find_by(role: role(key))
  end
end
