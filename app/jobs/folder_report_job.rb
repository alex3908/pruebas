# frozen_string_literal: true

require "caxlsx"

class FolderReportJob < ApplicationJob
  include ActionView::Helpers::NumberHelper, DateHelper, QuotationsHelper
  queue_as :low_priority
  ACTIVE_PROMISE_INDEX = 4

  def perform(user_id, status, folder_ids, for_reports_view)
    status.add_progress!("Generando reporte de expedientes...")
    user = User.find(user_id)
    can_set_purchase_promise_active = user.can?(:set_ready_state, Folder)
    steps_names = Step.all.pluck(:name).map!(&:upcase)

    folders = Folder.includes(:payment_scheme, :client, :client_2, :client_3, :client_4, :client_5, :client_6, [lot: [stage: :phase]], [user: :structure]).where(id: folder_ids)

    status.add_progress!("Creando hoja de cálculo...")

    is_evo = Role.where(is_evo: true).exists?
    specialist_concept = FolderUserConcept.find_by_key(:customer_service_specialist)

    begin
      report = Tempfile.new([ status.file_name, ".xlsx" ], encoding: "ascii-8bit")

      evo_structure = Role.evo_structure
      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Expedientes") do |sheet|
          sheet.add_row generate_header(is_evo, can_set_purchase_promise_active, steps_names, specialist_concept, evo_structure, for_reports_view)
          folders.each { |folder| sheet.add_row(generate_row(folder, is_evo, can_set_purchase_promise_active, specialist_concept, evo_structure, for_reports_view), types: generate_types(can_set_purchase_promise_active, for_reports_view)) }
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

    def generate_row(folder, is_evo, can_set_purchase_promise_active, specialist_concept, evo_structure, for_reports_view)
      client_profile = folder.client.get_person
      financed_type = folder.payment_scheme.total_payments <= 12 ? "Contado" : "Financiamiento"
      down_payment_type = folder.payment_scheme.down_payment_finance == 1 ? "Enganche de contado" : "Enganche diferido"
      down_payment = folder.total_down_payment
      down_payment_percentage = "#{'%.2f' % (folder.down_payment_percentage * 100)}%"
      approved_date = folder.approved_date.present? ? folder.approved_date.strftime("%F") : ""
      quotation = folder.generate_quote
      contract_active = folder.active? ? "ACTIVA" : "NO ACTIVA"
      operation_days = folder.approved_date.nil? ? (Time.now.to_date - folder.calc_date.to_date).to_i : (folder.approved_date.to_date - folder.calc_date.to_date).to_i
      purchase_promise_upload_date = folder.documents.find_template(:purchase_promise).try(:latest_file_version).try(:created_at)
      previous_steps_ids = Step.where("steps.order < (?)", folder&.step&.order).pluck(:id)
      row = Array.new
      canceled_description = Array.new
      canceled_description << folder.canceled_description if folder.canceled_description.present?
      cancelation_questions = Evaluation.where(question_type: :cancel).pluck(:id)
      cancelation_evaluations = folder.evaluation_folders.where("evaluation_id IN (?) AND answer = (?)", cancelation_questions, "Si")
      cancelation_evaluations.each do |cancelation_evaluation|
        canceled_description << cancelation_evaluation.evaluation.question
      end

      common_elements = [
        folder.id,
        folder.created_at.strftime("%F"),
        approved_date
      ]

      row_for_reports_view = [
        operation_days,
        contract_active,
        purchase_promise_upload_date&.strftime("%d/%m/%Y"),
        folder.project.name,
        folder.phase.name,
        folder.stage.name,
        folder.lot.name,
        folder.lot.area,
        folder.payment_scheme.buy_price,
        "'#{folder.stp_clabe}'",
        quotation.discount,
        folder.payment_scheme.name,
        quotation.total_with_discount,
        folder.user.label,
        folder.user.email,
        folder.client.label,
        folder.client.email,
        folder.client.lead_source&.name,
        folder.client_2&.label,
        folder.client_2&.email,
        folder.client_3&.label,
        folder.client_3&.email,
        folder.client_4&.label,
        folder.client_4&.email,
        folder.client_5&.label,
        folder.client_5&.email,
        folder.client_6&.label,
        folder.client_6&.email,
        folder.status_label,
        folder.user.branch&.name,
        client_profile&.state,
        responsibles(folder),
        financed_type,
        folder.payment_scheme.name,
        down_payment_type,
        down_payment,
        down_payment_percentage,
        folder.payment_scheme.down_payment_finance,
        folder.payment_scheme.initial_payment,
        only_date(folder.first_financing&.date),
        only_date(folder.initial_payment&.date),
        only_date(folder.first_down_payment&.date),
        folder.lot.area,
        folder.user.branch&.name,
        folder.commission_duration,
        folder.lot.reference,
        folder.payment_scheme.promotion_name,
        folder.payment_scheme.promotion_discount * 100,
        folder.payment_scheme.operation_label,
        canceled_description.join(", "),
        quotation.initial_periods.first.present? ? quotation.initial_periods.first[:amount] : "",
        quotation.initial_periods.first.present? ? quotation.initial_periods.first[:payments] : "",
        quotation.initial_periods.second.present? ? quotation.initial_periods.second[:amount] : "",
        quotation.initial_periods.second.present? ? quotation.initial_periods.second[:payments] : "",
        quotation.initial_periods.third.present? ? quotation.initial_periods.third[:amount] : "",
        quotation.initial_periods.third.present? ? quotation.initial_periods.third[:payments] : "",
      ]

      row_for_folders_view = [
        folder.project.name,
        folder.phase.name,
        folder.stage.name,
        folder.lot.name,
        folder.lot.area,
        quotation.discount,
        folder.payment_scheme.name,
        quotation.total_with_discount,
        folder.user.label,
        folder.client.label,
        folder.client.email,
        folder.client_2&.label,
        folder.client_3&.label,
        folder.client_4&.label,
        folder.client_5&.label,
        folder.client_6&.label,
        folder.status_label,
        folder.payment_scheme.total_payments,
        folder.payment_scheme.down_payment_finance,
        folder.payment_scheme.initial_payment,
        folder.payment_scheme.down_payment,
      ]

      row.concat(common_elements)
      row.concat(for_reports_view ? row_for_reports_view : row_for_folders_view)

      row << folder.folder_users.find_by(folder_user_concept_id: specialist_concept.id).try(:user).try(:label) if specialist_concept.present?

      if is_evo && folder.user.structure.present?
        evo_concepts = FolderUserConcept.where("key in (?, ?)", FolderUser::CONCEPT[:FOLLOW_UP], FolderUser::CONCEPT[:SALE])
        staff_structure = responsibles_structure(folder.folder_users.where(folder_user_concept: evo_concepts).includes(:user, :role).where.not(roles: { level: nil }))
        evo_structure.each do |evo_level|
          row << staff_structure[evo_level.key]&.user&.label
          row << staff_structure[evo_level.key]&.user&.email
        end
      else
        row.concat ["", "", "", "", "", "", "", ""]
        row << folder.user.label
        row << folder.user.email
        row.concat ["", ""]
      end

      row.delete_at(ACTIVE_PROMISE_INDEX) unless can_set_purchase_promise_active

      previous_steps_ids.each do |step_id|
        row << folder.step_logs.where(step_id: step_id).last&.moved_at&.strftime("%d/%m/%Y")
      end
      row
    end

    def generate_types(can_set_purchase_promise_active, for_reports_view)
      if for_reports_view
        types = [
          :string, # FOLIO
          :string, # FECHA CRM
          :string, # FECHA CRM FINAL APROBADO TESORERIA
          :integer, # DIAS DE OPERACION
          :string, # PROMESA ACTIVA
          :string, # FECHA DE CARGA DE PROMESA DE COMPRA
          :string, # PROYECTO
          :string, # FASE
          :string, # ETAPA
          :string, # UNIDAD
          :float, # MT2
          :float, # PRECIO SIN DCTO MT2
          :string, # STP
          :string, # DESCUENTO
          :string, # PLAN
          :float, # COSTO
          :string, # NOMBRE_ASESOR
          :string, # CORREO_ASESOR
          :string, # NOMBRE CLIENTE
          :string, # CORREO CLIENTE
          :string, # ORIGEN CLIENTE
          :string, # NOMBRE COPROPIETARIO 2
          :string, # CORREO COPROPIETARIO 2
          :string, # NOMBRE COPROPIETARIO 3
          :string, # CORREO COPROPIETARIO 3
          :string, # NOMBRE COPROPIETARIO 4
          :string, # CORREO COPROPIETARIO 4
          :string, # NOMBRE COPROPIETARIO 5
          :string, # CORREO COPROPIETARIO 5
          :string, # NOMBRE COPROPIETARIO 6
          :string, # CORREO COPROPIETARIO 6
          :string, # STATUS
          :string, # GRUPO
          :string, # ORIGEN DEL CLIENTE
          :string, # RESPONSABLES
          :string, # MÉTODO DE PAGO
          :string, # PLAZO
          :string, # COMENTARIOS
          :float, # ENGANCHE/ANTICIPO
          :float, # PORCENTAJE DE ENGANCHE
          :integer, # MESES DE ENGANCHE
          :float, # MONTO DE APARTADO
          :string, # FECHA DE LA PRIMERA PARCIALIDAD
          :string, # FECHA DEL APARTADO
          :string, # FECHA DEL ENGANCHE
          :float, # SUPERFICIE
          :string, # PROCEDENCIA
          :integer, # PLAZO EN MESES DE LA PROMOCIÓN
          :string, # CLAVE
          :string, # NOMBRE DE PROMOCIÓN
          :float, # PORCENTAJE DE PROMOCIÓN
          :string, # OPERACIÓN DE LA PROMOCIÓN
          :string, # MOTIVOS DE CANCELACIÓN
          :float, # MONTO PRIMER ACTUALIZACIÓN
          :float, # TOTAL PAGOS PRIMER ACTUALIZACIÓN
          :float, # MONTO SEGUNDA ACTUALIZACIÓN
          :float, # TOTAL PAGOS SEGUNDA ACTUALIZACIÓN
          :float, # MONTO TERCERA ACTUALIZACIÓN
          :float, # TOTAL PAGOS TERCERA ACTUALIZACIÓN
        ]
      else
        types = [
          :string, # FOLIO
          :string, # FECHA CRM
          :string, # FECHA CRM FINAL APROBADO TESORERIA
          :string, # PROYECTO
          :string, # FASE
          :string, # ETAPA
          :string, # UNIDAD
          :float, # MT2
          :string, # DESCUENTO
          :string, # PLAN
          :float, # COSTO
          :string, # NOMBRE_ASESOR
          :string, # NOMBRE CLIENTE
          :string, # CORREO CLIENTE
          :string, # NOMBRE COPROPIETARIO 2
          :string, # NOMBRE COPROPIETARIO 3
          :string, # NOMBRE COPROPIETARIO 4
          :string, # NOMBRE COPROPIETARIO 5
          :string, # NOMBRE COPROPIETARIO 6
          :string, # STATUS
          :string, # PLAZO
          :integer, # MESES DE ENGANCHE
          :float, # MONTO DE APARTADO
          :float, # ENGANCHE/ANTICIPO
        ]
      end

      types.delete_at(ACTIVE_PROMISE_INDEX) unless can_set_purchase_promise_active
      types
    end

    def generate_header(is_evo, can_set_purchase_promise_active, steps_names, specialist_concept, evo_structure, for_reports_view)
      if for_reports_view
        header = ["FOLIO",
          "FECHA CRM",
          "FECHA CRM FINAL APROBADO TESORERÍA",
          "DÍAS DE OPERACIÓN",
          "PROMESA ACTIVA",
          "FECHA DE CARGA DE PROMESA DE COMPRA",
          "PROYECTO",
          "FASE",
          "ETAPA",
          "UNIDAD",
          "MT2",
          "PRECIO SIN DCTO MT2",
          "STP",
          "DESCUENTO",
          "PLAN",
          "COSTO",
          "NOMBRE ASESOR",
          "CORREO ASESOR",
          "NOMBRE CLIENTE",
          "CORREO CLIENTE",
          "ORIGEN CLIENTE",
          "NOMBRE COPROPIETARIO 2",
          "CORREO COPROPIETARIO 2",
          "NOMBRE COPROPIETARIO 3",
          "CORREO COPROPIETARIO 3",
          "NOMBRE COPROPIETARIO 4",
          "CORREO COPROPIETARIO 4",
          "NOMBRE COPROPIETARIO 5",
          "CORREO COPROPIETARIO 5",
          "NOMBRE COPROPIETARIO 6",
          "CORREO COPROPIETARIO 6",
          "STATUS",
          "GRUPO",
          "ORIGEN DEL CLIENTE",
          "RESPONSABLES",
          "MÉTODO DE PAGO",
          "PLAZO",
          "COMENTARIOS",
          "ENGANCHE/ANTICIPO",
          "PORCENTAJE DE ENGANCHE",
          "MESES DE ENGANCHE",
          "MONTO DE APARTADO",
          "FECHA DE LA PRIMERA PARCIALIDAD",
          "FECHA DEL APARTADO",
          "FECHA DEL ENGANCHE",
          "SUPERFICIE",
          "PROCEDENCIA",
          "PLAZO EN MESES DE LA COMISIÓN",
          "CLAVE",
          "NOMBRE DE PROMOCIÓN",
          "PORCENTAJE DE PROMOCIÓN",
          "OPERACIÓN DE LA PROMOCIÓN",
          "MOTIVOS DE CANCELACIÓN",
          "MONTO PRIMER ACTUALIZACIÓN",
          "TOTAL PAGOS PRIMER ACTUALIZACIÓN",
          "MONTO SEGUNDA ACTUALIZACIÓN",
          "TOTAL PAGOS SEGUNDA ACTUALIZACIÓN",
          "MONTO TERCERA ACTUALIZACIÓN",
          "TOTAL PAGOS TERCERA ACTUALIZACIÓN"
        ]
      else
        header = ["FOLIO",
          "FECHA DE INICIO",
          "FECHA DE FINALIZACIÓN",
          "PROYECTO",
          "FASE",
          "ETAPA",
          "UNIDAD",
          "MT2",
          "DESCUENTO",
          "PLAN",
          "COSTO",
          "NOMBRE ASESOR",
          "NOMBRE CLIENTE",
          "CORREO CLIENTE",
          "NOMBRE COPROPIETARIO 2",
          "NOMBRE COPROPIETARIO 3",
          "NOMBRE COPROPIETARIO 4",
          "NOMBRE COPROPIETARIO 5",
          "NOMBRE COPROPIETARIO 6",
          "STATUS",
          "MESES DE FINANCIAMIENTO",
          "MESES DE ENGANCHE",
          "MONTO DE APARTADO",
          "MONTO DE ENGANCHE"
        ]
      end

      header << "ESPECIALISTA DE ATENCIÓN A CLIENTES" if specialist_concept

      if is_evo
        evo_structure.each do |role|
          header << "NOMBRE #{role.name.upcase}"
          header << "CORREO #{role.name.upcase}"
        end
      else
        header << "NOMBRE ASESOR"
        header << "CORREO ASESOR"
      end

      header.delete_at(ACTIVE_PROMISE_INDEX) unless can_set_purchase_promise_active
      header.concat steps_names
      header
    end

    def responsibles(folder)
      folder_users = []

      folder.folder_users.includes(:user, :folder_user_concept).each do |folder_user|
        folder_users << "#{folder_user.user.label} (#{number_to_percentage(folder_user.percentage, precision: 2)} - #{folder_user.folder_user_concept.name})"
      end

      folder_users.join(", ")
    end

    def responsibles_structure(folder_users)
      responsibles_roles = Hash.new
      folder_users.each do |user|
        responsibles_roles[user.role.key] = user if responsibles_roles[user.role.key].nil?
      end
      responsibles_roles
    end
end
