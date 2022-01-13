# frozen_string_literal: true

require "caxlsx"

class DelayedRestructuresReportJob < ApplicationJob
  queue_as :low_priority

  def perform(status, payment_ids)
    status.add_progress!("Generando reporte de prórrogas...")
    payments = Payment.includes([:restructure, installment: [folder: [:payment_scheme, lot: [stage: :phase], user: :structure]]]).where(id: payment_ids)

    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Pagos") do |sheet|
          sheet.add_row generate_header
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

    def generate_row(payment)
      folder = payment.installment.folder

      [
          folder.id,
          folder.approved_date&.strftime("%d/%m/%Y"),
          payment.client.label,
          folder.project.name,
          folder.phase.name,
          folder.stage.name,
          folder.lot.name,
          payment.restructure.concept_label,
          payment.restructure.delay_months,
          get_delay_amount(payment).round(2),
          payment.status_label,
      ]
    end

    def generate_header
      project_singular = Setting.find_by(key: "project_singular")&.value || "Proyecto"
      phase_singular = Setting.find_by(key: "phase_singular")&.value || "Fase"
      stage_singular = Setting.find_by(key: "stage_singular")&.value || "Etapa"

      [
          "Folio del expediente",
          "Fecha que entró al estatus Finalizado",
          "Nombre del cliente",
          "Nombre del #{project_singular}",
          "Nombre de la #{phase_singular}",
          "Nombre de la #{stage_singular}",
          "Número de lote",
          "Tipo de prórroga",
          "Meses prorrogados",
          "Monto total prorrogado",
          "Estado",
      ]
    end

    def get_delay_amount(payment)
      restructures = payment.installment.folder.get_restructures(payment)
      quotation = payment.installment.folder.generate_quote(nil, nil, restructures)
      payment_number = payment.installment.number.to_i
      delay_months = payment.installment.number.to_i + payment.restructure.delay_months - 1
      quotation.amr.select { |installment| installment[:number].to_i >= payment_number && installment[:number].to_i <= delay_months }.inject(0) { |sum, installment| sum + installment[:capital] + installment[:interest] }
    end
end
