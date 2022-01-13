# frozen_string_literal: true

require "caxlsx"

class FolderImportJob < ApplicationJob
  include ExportExcelErrors
  queue_as :low_priority

  def perform(job_status)
    job_status.add_progress!("Importando expedientes ...")
    file = Tempfile.new([job_status.file_name, ".xlsx"], encoding: "ascii-8bit")
    file.binmode
    excel_rows = []
    folders_ids = []
    columns_with_error = []

    job_status.add_progress!("Leyendo hoja de cálculo...")
    begin
      file.write(job_status.file.download)
      file.rewind

      book = Roo::Spreadsheet.open(file.path)
      sheet = book.sheet(0)

      begin
        sheet.each_with_index(header) do |row, index|
          ActiveRecord::Base.transaction do
            next if index == 0
            user = User.find_by(email: row[:user_email].try(:strip).try(:downcase))
            if user.nil?
              job_status.add_progress!("Generando usuario: #{row[:user_email].try(:strip).try(:downcase)}...")

              branch = Branch.find_by(name: row[:user_branch])
              branch = Branch.create!(name: row[:user_branch]) if branch.nil?

              role = Role.find_by(name: row[:user_role])
              # TODO: find a role with reserve permission
              role = Role.find_by!(key: :salesman) if role.nil?

              user = User.create!(
                email: row[:user_email].try(:strip).try(:downcase),
                first_name: row[:user_name],
                last_name: row[:user_last_name],
                phone: row[:user_phone],
                branch: branch,
                birthdate: row[:user_birthdate],
                gender: row[:user_gender] == "M" ? "male" : "female",
                written_rfc: row[:user_rfc],
                written_curp: row[:user_curp],
                role: role,
                password: SecureRandom.hex(8)
              )
              user.invite!
            end
            Current.user = user

            client = Client.find_by(email: row[:client_email].try(:strip).try(:downcase))
            if client.nil?
              job_status.add_progress!("Generando cliente: #{row[:client_email].try(:strip).try(:downcase)}...")

              client = Client.create!(
                email: row[:client_email].try(:strip).try(:downcase),
                name: row[:client_names],
                first_surname: row[:client_first],
                second_surname: row[:client_second],
                main_phone: row[:client_main_phone],
                optional_phone: row[:client_optional_phone],
                person: row[:client_person] == "Moral" ? "moral" : "physical",
                gender: row[:client_gender] == "M" ? "male" : "female",
                user: user,
              )
            end

            project = Project.find_by(name: row[:project_name])
            phase = Phase.find_by(name: row[:phase_name], project: project)
            stage = Stage.find_by(name: row[:stage_name], phase: phase)

            if row[:lot_id].present?
              job_status.add_progress!("Buscando lote con ID #{row[:lot_id]}...")
              lot = Lot.find(row[:lot_id])
            else
              job_status.add_progress!("Buscando lote con nombre #{row[:lot_number]} #{row[:lot_label]}...")
              lot = Lot.find_by!(number: row[:lot_number], label: row[:lot_label], stage: stage)
            end

            job_status.add_progress!("Generando expediente ligado al lote: #{lot.id}...")

            step = Step.find_by(name: row[:status])
            step ||= Step.first_step


            folder = Folder.new
            folder.payment_scheme = PaymentScheme.new

            folder.lot = lot
            folder.user = user
            folder.client = client
            folder.status = "active"
            folder.step = step
            folder.start_date = row[:start_date]
            folder.buyer = row[:buyer] != "Propiedad" ? "owner" : "coowner"

            payment_name = row[:total_payments] == 1 ? "Contado" : "#{row[:total_payments]} meses"
            promotion_operation = "over"
            if row[:promotion_formula] == "Suma"
              promotion_operation = "addition"
            elsif row[:promotion_formula] == "Mayor"
              promotion_operation = "higher"
            end

            job_status.add_progress!("Generando esquema de pagos ligado al lote: #{lot.id}...")
            folder.payment_scheme.assign_attributes(
              folder: folder,
              name: payment_name,
              initial_payment: row[:initial_payment],
              lock_payment: row[:initial_payment],
              discount: row[:discount],
              total_payments: row[:total_payments],
              down_payment_finance: row[:dp_finance],
              down_payment: row[:down_payment],
              buy_price: row[:buy_price],
              first_payment: row[:first_payment],
              start_installments: row[:start_installments],
              promotion_discount: row[:promotion_percentage],
              promotion_name: row[:promotion_name],
              promotion_operation: promotion_operation,
              opening_commission: row[:opening_commission],
              credit_scheme: CreditScheme.first
            )

            folder.save!
            folder.lot.update!(status: Lot::STATUS[:RESERVED])
            job_status.add_progress!("Expediente creado con id: #{folder.id}")
            folders_ids << folder.id
          rescue StandardError => ex
            job_status.add_progress!("Error fila #{index}: #{ex.message}")
            excel_rows << build_excel_row(row, ex.message)
          end
        end
      rescue Roo::HeaderRowNotFoundError => ex
        columns_with_error = JSON.parse(ex.message)
        error_message = "Las siguientes columnas no fueron encontradas en el archivo: #{columns_with_error.join(", ")}."
        job_status.add_progress!(error_message)
        job_status.mark_failed!(error_message)
        job_status.log_error!(ex)
      end

      job_status.add_progress!("Expedientes creados: #{folders_ids.join(', ')}")
      job_status.add_progress!("Limpiando proceso...")
    ensure
      file.close
      file.unlink
    end

    job_status.file.purge if job_status.file.present?
    (job_status = attach_excel_file(excel_rows, job_status, "Expedientes")) if excel_rows.size > 0

    if columns_with_error.empty?
      job_status.mark_completed!
    end
  rescue StandardError => e
    job_status.mark_failed!(e.to_s)
    job_status.log_error!(e)
    Bugsnag.notify(e)
  end


  private

    def header
      {
        user_email: "Correo del Usuario",
        user_name: "Nombre del Usuario",
        user_last_name: "Apellido del Usuario",
        user_phone: "Teléfono del Usuario",
        user_branch: "Sucursal del Usuario",
        user_birthdate: "Fecha de Cumpleaños del Usuario",
        user_gender: "Género del Usuario",
        user_rfc: "RFC del Usuario",
        user_curp: "CURP del Usuario",
        user_role: "Rol del Usuario",
        client_names: "Nombre del Cliente",
        client_first: "Primer Apellido del Cliente",
        client_second: "Segundo Apellido del Cliente",
        client_main_phone: "Teléfono Principal del Cliente",
        client_optional_phone: "Teléfono Opcional del Cliente",
        client_email: "Correo del Cliente",
        client_gender: "Género del Cliente",
        client_person: "Tipo de Persona del Cliente",
        project_name: "Nombre del Proyecto",
        phase_name: "Nombre de la Fase",
        stage_name: "Nombre de la Etapa",
        lot_number: "Número del Lote",
        lot_label: "Clasificador del Lote",
        lot_id: "ID de Lote",
        status: "Estado del Expediente",
        start_date: "Fecha Inicial",
        initial_payment: "Apartado",
        discount: "Descuento",
        total_payments: "Total de Pagos",
        dp_finance: "Financiamiento del Enganche",
        down_payment: "Saldo del Enganche",
        buy_price: "Precio por m2",
        first_payment: "Dias para Pago de Enganche",
        start_installments: "Meses para Pago de Financiamiento",
        promotion_name: "Nombre de la Promoción",
        promotion_percentage: "Porcentaje de Promoción",
        promotion_formula: "Formula de la Promoción",
        opening_commission: "Comisión por apertura",
        buyer: "Tipo de Comprador"
      }
    end

    def excel_header
      [
        "Correo del Usuario",
        "Nombre del Usuario",
        "Apellido del Usuario",
        "Teléfono del Usuario",
        "Sucursal del Usuario",
        "Fecha de Cumpleaños del Usuario",
        "Género del Usuario",
        "RFC del Usuario",
        "CURP del Usuario",
        "Rol del Usuario",
        "Nombre del Cliente",
        "Primer Apellido del Cliente",
        "Segundo Apellido del Cliente",
        "Teléfono Principal del Cliente",
        "Teléfono Opcional del Cliente",
        "Correo del Cliente",
        "Género del Cliente",
        "Tipo de Persona del Cliente",
        "Nombre del Proyecto",
        "Nombre de la Fase",
        "Nombre de la Etapa",
        "Número del Lote",
        "Clasificador del Lote",
        "ID de Lote",
        "Estado del Expediente",
        "Fecha Inicial",
        "Apartado",
        "Descuento",
        "Total de Pagos",
        "Financiamiento del Enganche",
        "Saldo del Enganche",
        "Precio por m2",
        "Dias para Pago de Enganche",
        "Meses para Pago de Financiamiento",
        "Nombre de la Promoción",
        "Porcentaje de Promoción",
        "Formula de la Promoción",
        "Comisión por apertura",
        "Tipo de Comprador",
        "Observaciones"
      ]
    end
end
