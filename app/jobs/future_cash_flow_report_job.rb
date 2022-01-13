# frozen_string_literal: true

require "caxlsx"

class FutureCashFlowReportJob < ApplicationJob
  include QuotationsHelper
  queue_as :low_priority

  def perform(status, search_params)
    status.add_progress!("Generando reporte de flujos...")

    steps_ids = Step.where(installments_step: true).pluck(:id)
    installments = Installment.includes(folder: [:step]).where("steps.id" => steps_ids).search(search_params)

    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([ status.file_name, ".xlsx" ], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Flujos") do |sheet|
          sheet.add_row generate_header
          installments.each do |installment|
            sheet.add_row(generate_row(installment))
          end
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

    def generate_row(installment)
      [
        installment.folder.id,
        installment.number,
        installment.concept,
        installment.down_payment,
        installment.capital,
        installment.interest,
        installment.total,
        installment.debt,
        installment.folder.client.label,
        installment.folder.project.name,
        installment.folder.phase.name,
        installment.folder.stage.name,
        installment.folder.lot.name,
        installment.folder.lot.area,
        folder_total(installment.folder)
      ]
    end

    def generate_header
      [
        "FOLIO DE LA VENTA",
        "NUMERO DE PAGO",
        "CONCEPTO",
        "ENGANCHE",
        "CAPITAL",
        "INTERES",
        "TOTAL",
        "SALDO",
        "CLIENTE",
        "PROYECTO",
        "FASE",
        "ETAPA",
        "UNIDAD",
        "SUPERFICIE M2",
        "PRECIO DE LISTA"
      ]
    end

    def folder_total(folder)
      total = folder.payment_scheme.buy_price * folder.lot.area
      promo = promotion_calculator(total, folder.payment_scheme.discount, folder.payment_scheme.promotion_discount, folder.payment_scheme.promotion_operation, folder.payment_scheme.promotion&.amount || 0, folder.payment_scheme.promotion&.operation || nil, folder.payment_scheme.coupon&.promotion&.amount || 0, folder.payment_scheme.coupon&.promotion&.operation || nil)
      promo.total
    end
end
