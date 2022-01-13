# frozen_string_literal: true

require "caxlsx"

class ClientsReportJob < ApplicationJob
  include ActionView::Helpers::NumberHelper, DateHelper
  queue_as :low_priority

  def perform(status, params)
    status.add_progress!("Generando reporte de clientes...")

    clients = Client.all

    structure_filter = filter_by_structure(params) if last_level_selected(params).present?
    concept_filter = filter_by_concept(params)

    clients = clients.where("created_at >= ?", params[:from_date].to_time.strftime("%Y-%m-%d 00:00:00")) if params[:from_date].present?
    clients = clients.where("created_at <= ?", params[:to_date].to_time.strftime("%Y-%m-%d 23:59:59")) if params[:to_date].present?
    clients = clients.where(id: structure_filter) if structure_filter.present?
    clients = clients.where(id: concept_filter) if concept_filter.present?
    clients = clients.where(lead_source_id: params[:lead_source]) if params[:lead_source].present?

    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")
      status.add_progress!("Guardando hoja de cálculo...")

      roles = Role.evo_structure
      concepts = ClientUserConcept.custom.where(max_users: 1)

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Clientes") do |sheet|
          sheet.add_row generate_header(concepts, roles)
          clients.each { |client| sheet.add_row generate_row(concepts, roles, client), types: generate_types(concepts, roles) }
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

    def generate_row(concepts, roles, client)
      row = Array.new

      sales_structure = client.sales_executive&.structure
      role_level = client.sales_executive&.role&.level

      roles_structure = roles.map { |role| [sales_structure&.path&.at_depth(role.level)&.first, role.level] }
      roles_structure = roles_structure.map do |role_structure|
        if role_level.present? && role_structure.second <= role_level
          role_structure[1] = true
        else
          role_structure[1] = false
        end
        role_structure
      end

      row << client.label
      row << client.email
      row << client.main_phone
      row << client.lead_source&.name
      row << only_date(client.created_at)
      row << client.quote_logs.order("creation_date ASC")&.first&.creation_date
      row << client.folders.where(status: :active).any?

      roles_structure.each do |structure|
        if !structure.first.nil? && structure.first.user.present?
          row << structure.first.user.label
          row << structure.first.user.email
        elsif structure.second
          row << "Sin Responsable"
          row << "-"
        else
          row << ""
          row << ""
        end
      end

      concepts.each do |concept|
        user = client.client_users.find_by(client_user_concept: concept)&.user
        if !user.nil?
          row << user.label
          row << user.email
        else
          row << nil
          row << nil
        end
      end

      row
    end

    def generate_types(concepts, roles)
      roles_types = (1..roles.count).flat_map { |i| [:string, :string] }
      concepts_types = (1..concepts.count).flat_map { |i| [:string, :string] }
      [:string, :string, :string, :string, :string, :string, :boolean] + roles_types + concepts_types
    end

    def generate_header(concepts, roles)
      concept_names = concepts.flat_map { |c| ["Nombre " + c.name, "Email " + c.name] }
      roles_names = roles.flat_map { |r| ["Nombre " + r.name, "Email " + r.name] }

      ["Nombre", "Correo", "Teléfono", "Origen", "Fecha de Registro", "Fecha de Última cotización", "Cuenta con venta"] + roles_names + concept_names
    end

    def filter_by_concept(concept)
      clients_ids = []

      concept.each do |(user_id, concept_id)|
        break if user_id.to_s.blank? || concept_id.to_s.blank?
        clients_ids << ClientUser.where(user_id: user_id.to_s, client_user_concept_id: concept_id.to_s).pluck(:client_id)
      end
      return nil if clients_ids.empty?
      clients_ids.flatten
    end

    def filter_by_structure(params)
      sales_executive = ClientUserConcept.sales_executive
      level_filter = last_level_selected(params)

      user_ids = Structure.find_by(user_id: level_filter).descendants.pluck(:user_id)
      user_ids << level_filter

      ClientUser.where(user_id: user_ids, client_user_concept: sales_executive).pluck(:client_id)
    end

    def last_level_selected(params)
      @last_level_selected ||= begin
        roles = {}
        leaders = []
        params.each do |key, value|
          next unless (key.to_s.include? "_node") && value.present?
          key = key.to_s.gsub("_node", "")
          leaders.push(key)
          roles[key] = value
        end

        return nil if leaders.empty?
        last_level = Role.where(key: leaders).order(level: :asc).last&.key
        roles[last_level]
      end
    end
end
