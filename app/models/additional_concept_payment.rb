# frozen_string_literal: true

class AdditionalConceptPayment < ApplicationRecord
  belongs_to :cash_flow
  belongs_to :additional_concept, with_deleted: true
  belongs_to :enterprise, required: false

  delegate :name, to: :additional_concept, prefix: true

  before_create :assign_enterprise

  def self.search(params:)
    payments = AdditionalConceptPayment.joins([cash_flow: [folder: [:client, :payment_scheme, lot: [stage: [phase: :project]], user: [:branch, :structure]]] ], :additional_concept)
    payments = payments.where("cash_flows.client_id": Client.where("LOWER(CONCAT(name, first_surname, second_surname)) LIKE LOWER(?)", "%#{params[:name].tr(" ", "%")}%".delete(" \t\r\n"))) if params[:name].present?
    payments = payments.where("cash_flows.client_id": Client.where("LOWER(email) LIKE LOWER(?)", "%#{params[:email]}%".delete(" \t\r\n"))) if params[:email].present?
    payments = payments.where("lots.number" => params[:lot_number].delete(" \t\r\n")) if params[:lot_number].present?
    payments = payments.where("LOWER(lots.label) = LOWER(?)", params[:lot_label]) if params[:lot_label].present?
    payments = payments.where("cash_flows.status": params[:status]) if params[:status].present?
    payments = payments.where("projects.id" => params[:project]) if params[:project].present?
    payments = payments.where("phases.id" => params[:phase]) if params[:phase].present?
    payments = payments.where("stages.id" => params[:stage]) if params[:stage].present?
    payments = payments.where("folders.id" => params[:folio]) if params[:folio].present?
    payments = payments.where("cash_flows.user_id": User.where("LOWER(CONCAT(first_name, last_name)) LIKE LOWER(?)", "%#{params[:salesman].tr(" ", "%")}%")) if params[:salesman].present?
    payments = payments.where("cash_flows.created_at BETWEEN ? and ?", params[:from_date].to_time.strftime("%Y-%m-%d 00:00:00"), params[:to_date].to_time.strftime("%Y-%m-%d 23:59:59")) if params[:from_date].present? && params[:to_date].present?
    payments
  end

  def assign_enterprise
    self.enterprise_id = additional_concept.enterprise_id
  end
end
