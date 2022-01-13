# frozen_string_literal: true

require "caxlsx"

class OnlinePaymentTicketsReportJob < ApplicationJob
  queue_as :low_priority

  def perform(status, filter_params)
    online_payment_ticket_ids = OnlinePaymentTicket.set_params(filter_params, "online_payment_tickets.created_at", "desc").pluck(:id)

    status.add_progress!("Generando reporte de pagos...")
    online_payment_tickets = OnlinePaymentTicket.includes(:folder, :client).where(id: online_payment_ticket_ids).order(id: :asc)

    status.add_progress!("Creando hoja de cálculo...")
    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Tickets de pago") do |sheet|
          sheet.add_row generate_header
          online_payment_tickets.each { |online_payment_ticket| sheet.add_row(generate_row(online_payment_ticket)) }
        end

        status.add_progress!("Guardando hoja de cálculo...")
        xlsx_package.serialize(report.path)

        status.add_progress!("Subiendo hoja de cálculo...")
        status.file.attach(io: File.open(report.path), filename: "#{status.file_name}.xlsx")
      end
      status.add_progress!("Limpiando proceso...")
    ensure
      report.close
      report.unlink
    end
    status.mark_completed!
  rescue StandardError => e
    status.mark_failed!(e.to_s)
    status.log_error!(e)
    raise e
  end

  private
    def generate_row(online_payment_ticket)
      concept = online_payment_ticket.concept.present? ? online_payment_ticket.concept.capitalize : "Pago aplicado a través del webhook"

      [
        online_payment_ticket.id,
        concept,
        online_payment_ticket.amount,
        I18n.t("activerecord.attributes.online_payment_ticket.statuses.#{online_payment_ticket.status}"),
        online_payment_ticket.folder.id,
        online_payment_ticket.client.label.capitalize,
        online_payment_ticket.client.email,
        online_payment_ticket.message&.capitalize,
        online_payment_ticket.online_payment_service&.provider&.capitalize
      ]
    end

    def generate_header
      [
        "TICKET DE PAGO",
        "CONCEPTO",
        "MONTO",
        "ESTADO",
        "FOLIO DEL EXPEDIENTE",
        "NOMBRE CLIENTE",
        "CORREO CLIENTE",
        "MENSAJE",
        "PROVEEDOR DEL SERVICIO DE PAGO"
      ]
    end
end
