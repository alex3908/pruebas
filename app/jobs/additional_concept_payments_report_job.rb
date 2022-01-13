# frozen_string_literal: true

require "caxlsx"

class AdditionalConceptPaymentsReportJob < ApplicationJob
  include AdditionalConceptsHelper
  queue_as :low_priority

  def perform(status, payment_ids)
    status.add_progress!("Generando reporte de pagos de servicios adicionales...")
    payments = AdditionalConceptPayment.includes([cash_flow: [folder: [:client, :payment_scheme, lot: [stage: [phase: :project]], user: [:branch, :structure]]] ], :additional_concept)

    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Pagos") do |sheet|
          sheet.add_row header
          payments.each { |payment| sheet.add_row(generate_row(payment)) }
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

    def header
      [
        "CLIENTE",
        "PROYECTO",
        "ETAPA",
        "PRIVADA",
        "LOTE",
        "CONCEPTO DE PAGO",
        "TIPO",
        "MONTO A PAGAR",
        "FOLIO DE PAGO",
        "MÉTODO DE PAGO",
        "BANCO/CAJA",
        "MONTO PAGADO",
        "FECHA DE APLICACIÓN DE PAGO* REGISTRO EN SISTEMA",
        "USUARIO QUE APLICÓ EL PAGO",
        "ESTATUS",
        "ASESOR"
      ].freeze
    end

    def generate_row(payment)
      cash_flow = payment.cash_flow
      folder = cash_flow.folder
      concept = payment.additional_concept
      [
        cash_flow.client.label,
        folder.project.name,
        folder.phase.name,
        folder.stage.name,
        folder.lot.name,
        concept.name,
        amount_type_label(concept.amount_type),
        concept.amount,
        cash_flow.folio || "No aplica",
        cash_flow.payment_method&.name || "Pago en línea",
        cash_flow.bank_account&.bank || "No aplica",
        cash_flow.amount,
        cash_flow.created_at.strftime("%d/%m/%Y"),
        cash_flow.user&.label || "No aplica",
        cash_flow.status_label,
        folder.user.label
      ]
    end
end
