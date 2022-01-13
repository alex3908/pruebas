# frozen_string_literal: true

require "caxlsx"

class PaymentReportJob < ApplicationJob
  include DateHelper
  queue_as :low_priority

  def perform(status, payment_ids)
    status.add_progress!("Generando reporte de pagos...")
    payments = Payment.includes([installment: [folder: [:payment_scheme, lot: [stage: :phase], user: :structure]]]).where(id: payment_ids)

    status.add_progress!("Creando hoja de cálculo...")

    is_evo = Role.where(is_evo: true).exists?

    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Pagos") do |sheet|
          sheet.add_row generate_header(is_evo)
          payments.each { |payment| sheet.add_row(generate_row(payment, is_evo)) }
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

    def generate_row(payment, is_evo)
      folder = payment.installment.folder
      payment_date = payment.cash_flow.present? ? payment.cash_flow.date.strftime("%d/%m/%Y") : payment.created_at.strftime("%d/%m/%Y")

      [
          folder.id,
          only_date(folder.approved_date),
          payment.client.label,
          folder.project.name,
          folder.phase.name,
          folder.stage.name,
          folder.lot.name,
          folder.lot.area,
          folder.payment_scheme.down_payment_finance,
          folder.payment_scheme.initial_payment,
          folder.payment_scheme.promotion_name || "No aplica",
          payment.installment.number,
          payment.installment.date,
          payment.installment.concept_label,
          payment.installment.total,
          payment&.cash_flow&.folio || "No aplica",
          payment_date,
          payment&.cash_flow&.payment_method&.name || "Pago en línea",
          payment&.cash_flow&.bank_account&.bank || "No aplica",
          payment.amount,
          only_date(payment.created_at),
          payment&.user&.label || "No aplica",
          payment.status_label,
          folder.status_label,
          date_hour(payment.cash_flow.cancellation_date),
          payment.cash_flow.canceled_by&.label,
          folder.user.label,

      ]
    end

    def generate_header(is_evo)
      ["FOLIO DE LA VENTA",
       "FECHA DEL ESTATUS FINALIZADO",
       "CLIENTE",
       "PROYECTO",
       "ETAPA",
       "PRIVADA",
       "UNIDAD",
       "SUPERFICIE M2",
       "PLAZO ENGANCHE",
       "APARTADO",
       "PROMOCIÓN",
       "NUMERO DE PAGO",
       "FECHA DE AMORTIZACIÓN",
       "CONCEPTO DE PAGO",
       "MONTO A PAGAR",
       "FOLIO DE PAGO",
       "FECHA DEL COMPROBANTE DE PAGO",
       "METODO DE PAGO",
       "BANCO/CAJA",
       "MONTO PAGADO",
       "FECHA DE APLICACIÓN DE PAGO* REGISTRO EN SISTEMA",
       "USUARIO QUE APLICÓ EL PAGO",
       "ESTATUS",
       "ESTATUS EXPEDIENTE",
       "FECHA DE CANCELACIÓN",
       "CANCELADO POR",
       "ASESOR",
      ]
    end
end
