# frozen_string_literal: true

require "caxlsx"

class OverdueBalanceReportJob < ApplicationJob
  include OverdueBalanceReportJobHandler
  queue_as :low_priority

  def perform(status, folder_ids)
    status.add_progress!("Generando reporte de saldos vencidos...")
    folders = Folder.includes(:payment_scheme, :client, :client_2, :client_3, :client_4, :client_5, :client_6, [lot: [stage: [phase: :project]]], [user: :structure]).where(id: folder_ids)

    status.add_progress!("Creando hoja de cálculo...")

    is_evo = Role.where(is_evo: true).exists?
    specialist_concept = FolderUserConcept.find_by_key(:customer_service_specialist)

    begin
      report = Tempfile.new([ status.file_name, ".xlsx" ], encoding: "ascii-8bit")

      evo_structure = Role.evo_structure
      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Pagos") do |sheet|
          sheet.add_row generate_header(is_evo, specialist_concept, evo_structure)
          folders.each do |folder|
            overdue_payments = get_overdue_payments(folder)
            sheet.add_row(generate_row(folder, overdue_payments, is_evo, specialist_concept, evo_structure))
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

    def generate_row(folder, overdue_payments, is_evo, specialist_concept, evo_structure)
      row = [
          folder.id,
          folder&.approved_date&.strftime("%d/%m/%Y"),
          folder.client.label,
          folder.project.name,
          folder.phase.name,
          folder.stage.name,
          folder.lot.name,
          folder.lot.area,
          overdue_payments[:total_with_discount],
          overdue_payments[:count_of_installments_paid],
          overdue_payments[:date_of_the_last_paid],
          overdue_payments[:amount_paid],
          overdue_payments[:count_of_overdue_payments],
          overdue_payments[:overdue_amount],
          overdue_payments[:expired_balance_percentage].round(2).to_s + "%",
          overdue_payments[:overdue_amount_down_payment].round(2),
          overdue_payments[:capital_interest_amount_overdue].round(2),
          overdue_payments[:days_expired],
          overdue_payments[:has_financing_subscription] ? "Sí" : "No",
          overdue_payments[:has_down_payment_subscription] ? "Sí" : "No",
          overdue_payments[:last_installment_day]&.strftime("%d/%m/%Y")
      ]

      row << folder.folder_users.find_by(folder_user_concept_id: specialist_concept.id).try(:user).try(:label) if specialist_concept.present?

      if is_evo && folder.user.structure.present?
        staff_structure = folder.user.structure.staff_structure(evo_structure)
        evo_structure.each do |evo_level|
          row << staff_structure[evo_level.key]&.user&.label
        end
      else
        row << folder.user.label
      end

      row
    end

    def generate_header(is_evo, specialist_concept, evo_structure)
      header = ["FOLIO DE LA VENTA",
                "FECHA DEL ESTATUS FINALIZADO",
                "CLIENTE",
                "PROYECTO",
                "ETAPA",
                "PRIVADA",
                "UNIDAD",
                "SUPERFICIE M2",
                "IMPORTE DE VENTA",
                "NUMERO DE LETRAS PAGADAS",
                "FECHA DE ULTIMA LETRA SALDADA",
                "MONTO TOTAL PAGADO",
                "NUMERO DE LETRAS VENCIDAD",
                "MONTO TOTAL VENCIDO",
                "PORCENTAJE DE SALDO VENCIDO",
                "MONTO TOTAL DE ENGANCHE VENCIDO",
                "MONTO DE CAPITAL + INTERÉS VENCIDO",
                "DÍAS DE VENCIMIENTO",
                "DOMICILIACIÓN DE ENGANCHE DIFERIDO",
                "DOMICILIACIÓN DE CAPITAL + INTERÉS",
                "DÍA DE PAGO VIGENTE"
      ]

      header << "ESPECIALISTA DE ATENCIÓN A CLIENTES" if specialist_concept

      if is_evo
        evo_structure.each do |role|
          header << role.name.upcase
        end
      end

      header
    end
end
