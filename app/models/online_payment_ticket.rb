# frozen_string_literal: true

class OnlinePaymentTicket < ApplicationRecord
  scope :successful, ->() { where(status: ["success", :success]) }

  STATUS = I18n.t("activerecord.attributes.online_payment_ticket.statuses")
  enum status: HashWithIndifferentAccess.new(success: "success", failed: "failed", error: "error", review: "review")

  CONCEPT_KEY = I18n.t("activerecord.attributes.online_payment_ticket.concept_keys")
  enum concept_key: HashWithIndifferentAccess.new(finance: "finance", reserve: "reserve", down_payment: "down_payment", balance_down: "balance_down", reserve_fee: "reserve_fee", financing: "financing", additional_concept: "additional_concept", initial_payment: "initial_payment", last_payment: "last_payment", balance_down_payment: "balance_down_payment", subscription: "subscription")

  belongs_to :client
  belongs_to :folder
  belongs_to :online_payment_service, optional: true

  after_save :load_tickets_into_folder, if: :success?

  def self.set_params(params, sort_column, sort_direction)
    order(sort_column + " " + sort_direction).search(params)
  end

  def self.search(params)
    online_payment_tickets = OnlinePaymentTicket.includes([:client, folder: [lot: [stage: [phase: :project]]]])
    online_payment_tickets = online_payment_tickets.where(client_id: Client.where("LOWER(CONCAT(name, first_surname, second_surname)) LIKE LOWER(?)", "%#{params[:name].tr(" ", "%")}%".delete(" \t\r\n"))) if params[:name].present?
    online_payment_tickets = online_payment_tickets.where(client_id: Client.where("LOWER(email) LIKE LOWER(?)", "%#{params[:email]}%".delete(" \t\r\n"))) if params[:email].present?
    online_payment_tickets = online_payment_tickets.where("lots.number" => params[:lot_number].delete(" \t\r\n")) if params[:lot_number].present?
    online_payment_tickets = online_payment_tickets.where("LOWER(lots.label) = LOWER(?)", params[:lot_label]) if params[:lot_label].present?
    online_payment_tickets = online_payment_tickets.where(status: params[:status]) if params[:status].present?
    online_payment_tickets = online_payment_tickets.where(concept_key: params[:concept]) if params[:concept].present?
    online_payment_tickets = online_payment_tickets.where("projects.id" => params[:project]) if params[:project].present?
    online_payment_tickets = online_payment_tickets.where("phases.id" => params[:phase]) if params[:phase].present?
    online_payment_tickets = online_payment_tickets.where("stages.id" => params[:stage]) if params[:stage].present?
    online_payment_tickets = online_payment_tickets.where("folders.id" => params[:folio]) if params[:folio].present?
    online_payment_tickets = online_payment_tickets.where("DATE(online_payment_tickets.created_at) BETWEEN ? and ?", params[:from_date].to_time.strftime("%Y-%m-%d"), params[:to_date].to_time.strftime("%Y-%m-%d")) if params[:from_date].present? && params[:to_date].present?
    online_payment_tickets
  end

  def load_tickets_into_folder
    if reserve? || down_payment?
      attach_pdf_to_document(folder.documents.find_template(:bank_deposit))
    end

    if balance_down? || down_payment?
      attach_pdf_to_document(folder.documents.find_template(:down_payment_voucher))
    end

    if reserve_fee?
      attach_pdf_to_document(folder.documents.find_template(:commission_voucher))
    end
  end

  def service
    online_payment_service
  end

  private
    def attach_pdf_to_document(document)
      ClientTicketJob.perform_later(document, self)
    end
end
