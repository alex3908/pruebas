# frozen_string_literal: true

require "caxlsx"

class SalesReportJob < ApplicationJob
  include ActionView::Helpers::NumberHelper, DateHelper, QuotationsHelper
  queue_as :low_priority
  ACTIVE_PROMISE_INDEX = 4

  def perform(status, filter_params)
    status.add_progress!("Generando reporte de expedientes...")

    folders = Folder.search(filter_params)

    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([ status.file_name, ".xlsx" ], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        wrap_text = xlsx_package.workbook.styles.add_style({ alignment: { horizontal: :center } })

        xlsx_package.workbook.add_worksheet(name: "Ventas realizadas") do |sheet|
          sheet.add_row generate_header, style: wrap_text
          folders.each { |folder| sheet.add_row generate_row(folder), style: wrap_text }
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

    def generate_row(folder)
      lot = folder.lot
      payment_scheme = folder.payment_scheme
      price = payment_scheme.buy_price * lot.area
      total_discount = payment_scheme.total_discount
      total_down_payment = payment_scheme.initial_payment + payment_scheme.down_payment
      initial_payment = folder.initial_payment
      financing_installments = folder.installments.where(concept: :financing)

      [
          folder.project.name,
          folder.stage.name,
          lot.id,
          lot.area,
          folder.client.label,
          folder.client.lead_source.present? ? folder.client.lead_source.name : "N/A",
          number_to_currency(price),
          total_discount > 0 ? number_to_currency(total_discount) : "N/A",
          number_to_currency(total_down_payment),
          number_to_currency(payment_scheme.down_payment),
          number_to_currency(financing_installments.sum(:capital)),
          number_to_currency(financing_installments.sum(:total)),
          number_to_currency(folder.total_sale),
          initial_payment.present? ? number_to_currency(payment_scheme.initial_payment) : "N/A",
          only_date(folder.start_date),
          initial_payment.present? && initial_payment.is_paid? ? validate_initial_payment(initial_payment) : "N/A",
          down_payment_payment_date(folder),
          folder.approved_date.present? ? only_date(folder.approved_date) : "N/A",
          last_financing_paid_date(folder)
      ]
    end

    def generate_header
      [
          "DESAROLLO",
          "ETAPA",
          "LOTE",
          "METROS CUADRADOS",
          "CLIENTE",
          "CANAL DE VENTAS",
          "PRECIO DE LISTA",
          "DESCUENTO",
          "TOTAL GENERAL DE ENGANCHE",
          "FLUJO DE ENGANCE",
          "MONTO FINANCIADO SIN INTERESES",
          "MONTO FINANCIADO CON INTERESES",
          "PRECIO FINAL",
          "APARTADO",
          "FECHA DE INICIO DE OPERACIÓN",
          "FECHA DE PAGO DE APARTADO",
          "FECHA DE FINALIZACIÓN DE ENGANCE",
          "FECHA DE VENTA",
          "FECHA DE FINALIZACIÓN DE FINANCIAMIENTO"
      ]
    end

    def down_payment_payment_date(folder)
      down_payment_installments = folder.down_payments_installments
      return "N/A" unless down_payment_installments.present?
      last_down_payment = down_payment_installments.last
      return "N/A" unless last_down_payment.is_paid?
      only_date(last_down_payment.payments.last.created_at)
    end

    def last_financing_paid_date(folder)
      processed_installments = folder.processed_installments
      last_installment = processed_installments.last
      return "N/A" unless last_installment.present? && last_installment.is_paid?
      return "N/A" unless folder.cash_flows.present?
      only_date(folder.cash_flows.last.date)
    end

    def validate_initial_payment(initial_payment)
      return 0 if initial_payment.total.zero?
      only_date(initial_payment.payments.last.created_at)
    end
end
