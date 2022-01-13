# frozen_string_literal: true

class ClientImportJob < ApplicationJob
  queue_as :low_priority

  def perform(job_status)
    job_status.add_progress!("Importando expedientes ...")
    file = Tempfile.new([job_status.file_name, ".xlsx"], encoding: "ascii-8bit")
    file.binmode

    job_status.add_progress!("Leyendo Excel...")
    begin
      file.write(job_status.file.download)
      file.rewind

      book = Roo::Spreadsheet.open(file.path)
      sheet = book.sheet(0)

      ActiveRecord::Base.transaction do
        sheet.each_with_index(
          name: "Nombres",
          first_surname: "Apellido 1",
          second_surname: "Apellido 2",
          main_phone: "Teléfono Principal",
          optional_phone: "Teléfono Adicional",
          email: "Email",
          person: "Tipo de Persona",
          gender: "Género",
          branch: "Sucursal",
          user_email: "Email del Asesor"
        ) do |row, index|
          next if index == 0
          client = Client.find_by(email: row[:email])
          if client.nil?
            job_status.add_progress!("Generando cliente: #{row[:name]} #{row[:first_surname]}")

            client_attrs = {}
            Current.user = User.find_by!(email: row[:user_email])

            row.keys.each do |key|
              if Client.column_names.include?(key.to_s)
                client_attrs[key] = row[key]
              end
            end

            case client_attrs[:gender]
            when "Masculino"
              client_attrs[:gender] = "male"
            when "Femenino"
              client_attrs[:gender] = "female"
            else
              raise "Género inválido para el cliente con email: #{client_attrs[:email]}"
            end

            case client_attrs[:person]
            when "Física"
              client_attrs[:person] = "physical"
            when "Moral"
              client_attrs[:person] = "moral"
            else
              raise StandardError.new("Tipo de persona inválido para el cliente con email: #{client_attrs[:email]}")
            end

            Client.create!(client_attrs)
          end
        end
      end
      job_status.add_progress!("Limpiando proceso...")
    ensure
      file.close
      file.unlink
    end

    job_status.mark_completed!
  rescue StandardError => e
    job_status.mark_failed!(e.to_s)
    job_status.log_error!(e)
  end
end
