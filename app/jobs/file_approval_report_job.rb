# frozen_string_literal: true

require "caxlsx"

class FileApprovalReportJob < ApplicationJob
  include FoldersHelper, FileApprovalsHelper
  queue_as :low_priority

  def perform(status, file_approvals_ids)
    status.add_progress!("Generando reporte de verificaciones...")
    file_approvals = FileApproval.where(id: file_approvals_ids)

    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([ status.file_name, ".xlsx" ], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Verificaciones") do |sheet|
          sheet.add_row generate_header
          file_approvals.each { |file_approval| sheet.add_row(generate_row(file_approval)) }
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

    def generate_row(file_approvals)
      [
          file_approvals.approvable.id,
          file_approvals.approvable.client.label,
          file_approvals.approvable.lot.stage.phase.project.name,
          file_approvals.approvable.lot.stage.phase.name,
          file_approvals.approvable.lot.stage.name,
          file_approvals.approvable.lot.name,
          file_approvals.approvable.user&.branch&.name || "No aplica",
          file_approvals.created_at.strftime("%d/%m/%Y %H:%M"),
          file_approvals&.approved_at&.strftime("%d/%m/%Y %H:%M") || "No aplica",
          approval_label_name(file_approvals),
          approval_amount(file_approvals),
          approved_label_result(file_approvals),
      ]
    end

    def generate_header
      ["FOLIO DE LA VENTA",
               "CLIENTE",
               "PROYECTO",
               "ETAPA",
               "PRIVADA",
               "UNIDAD",
               "SUCURSAL",
               "FECHA DE SOLICITUD",
               "FECHA DE APROBACIÓN",
               "TIPO",
               "MONTO",
               "ESTADO",
     ]
    end
end
