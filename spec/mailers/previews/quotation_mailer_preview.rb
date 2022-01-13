# frozen_string_literal: true

class QuotationMailerPreview < ActionMailer::Preview
  def send_quotation
    client = Client.first
    lot = Lot.first
    @company_name = Setting.find_by(key: "company-name").try(:convert)

    QuotationMailer.send_quotation(fake_pdf, client, lot, FactoryBot.build(:user), @company_name)
  end

  def notify_user
    client = Client.first
    user = FactoryBot.build(:user)
    lot = Lot.first
    project = lot.project
    @company_name = Setting.find_by(key: "company-name").try(:convert)

    QuotationMailer.notify_user(user, client, lot, project.stage_entity_name, project.phase_entity_name, project.project_entity_name, @company_name)
  end

  def notify_project
    lot = Lot.first
    stage = lot.stage
    phase = stage.phase
    project_email = phase.project.email

    QuotationMailer.notify_project(project_email, lot)
  end

  def send_contact_information
    user = FactoryBot.build(:user)
    client = Client.first
    client_name = client.name
    client_last_name = client.first_surname
    phone = client.main_phone
    client_message = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."

    lot = Lot.first
    stage = lot.stage
    phase = stage.phase
    project = phase.project

    emails = []
    emails << project.email
    emails << user.email

    QuotationMailer.send_contact_information(emails, stage, phase, client_name, client_last_name, phone, client_message)
  end

  private
    # TODO: Replace with real quotation
    def fake_pdf
      "<html><body><h1 align='center'>Test Document</h1></body></html>"
    end
end
