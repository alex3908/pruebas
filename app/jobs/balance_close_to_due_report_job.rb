# frozen_string_literal: true

require "caxlsx"

class BalanceCloseToDueReportJob < ApplicationJob
  queue_as :low_priority

  def perform(status, folder_ids)
    status.add_progress!("Generando reporte de saldos por vencer...")
    folders = Folder.includes(:payment_scheme, :client, :client_2, :client_3, :client_4, :client_5, :client_6, [lot: [stage: :phase]], [user: :structure]).where(id: folder_ids)

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
            close_to_due_payments = get_close_to_due_payments(folder)
            sheet.add_row(generate_row(folder, close_to_due_payments, is_evo, specialist_concept, evo_structure))
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

    def generate_row(folder, balance_close_to_due, is_evo, specialist_concept, evo_structure)
      row = [
          folder.id,
          folder&.approved_date&.strftime("%d/%m/%Y"),
          folder.client.label,
          folder.project.name,
          folder.phase.name,
          folder.stage.name,
          folder.lot.name,
          folder.lot.area,
          balance_close_to_due[:total_with_discount],
          balance_close_to_due[:amount],
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
                "MONTO CERCA DE VENCER",
      ]

      header << "ESPECIALISTA DE ATENCIÓN A CLIENTES" if specialist_concept

      if is_evo
        evo_structure.each do |role|
          header << role.name.upcase
        end
      end
      header
    end

    def get_close_to_due_payments(folder)
      installments = folder.installments.includes(payments: :restructure)
      quotation = folder.generate_quote
      stage = folder.stage
      all_installments = quotation.down_payment_monthly_payments | quotation.amr
      balance_close_to_due = 0

      all_installments.each_with_index do |installment, index|
        is_down_payment = index + 1 <= quotation.down_payment_monthly_payments.length
        if index == 0
          concept = Installment::CONCEPT[:INITIAL_PAYMENT]
        elsif is_down_payment
          concept = Installment::CONCEPT[:DOWN_PAYMENT]
        else
          concept = Installment::CONCEPT[:FINANCING]
        end
        actual = installments.find { |element| (element.number.to_i == installment[:number] || element.number == "A") && element.concept == concept }
        total_amount = installment[:payment].round(2)
        pending_payment = 0

        if actual.present? && actual.total_paid < total_amount
          pending_payment = total_amount - actual.total_paid
        elsif actual.nil?
          pending_payment = total_amount
        end

        if installment[:date] >= Time.zone.now && installment[:date] < Time.zone.now.next_day(stage.payment_expiration) && pending_payment > 0
          balance_close_to_due += pending_payment
        end
      end

      {
          amount: balance_close_to_due,
          total_with_discount: folder.total_sale
      }
    end
end
