# frozen_string_literal: true

require "caxlsx"

class UsersReportJob < ApplicationJob
  include DateHelper
  queue_as :low_priority

  def perform(status, params)
    status.add_progress!("Generando reporte...")
    status.add_progress!("Creando hoja de cálculo...")

    users = User.all
    roles = Role.evo_structure

    structure_filter = filter_by_structure(params) if last_level_selected(params).present?

    users = users.where(id: structure_filter) if structure_filter.present?

    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Usuarios") do |sheet|
          sheet.add_row generate_header(roles)
          users.each_with_index { |user, idx| sheet.add_row(generate_row(user, params, roles)) }
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
    def generate_row(user, params, roles)
      row = Array.new

      structure = user&.structure
      role_level = user&.role&.level

      roles_structure = roles.map { |role| [structure&.path&.at_depth(role.level)&.first, role.level] }
      roles_structure = roles_structure.map do |role_structure|
        if role_level.present? && role_structure.second < role_level
          role_structure[1] = true
        else
          role_structure[1] = false
        end
        role_structure
      end

      row << user.label
      row << user.email
      row << user.role&.name
      row << user.activated_at.present? ? only_date(user.activated_at) : ""
      row << user.disabled_at.present? ? only_date(user.disabled_at) : ""

      roles_structure.each do |stru|
        if !stru.first.nil? && stru.first.user.present?
          row << stru.first.user.label
          row << stru.first.user.email
        elsif stru.second
          row << "Sin Responsable"
          row << "-"
        else
          row << ""
          row << ""
        end
      end

      row
    end

    def generate_header(roles)
      roles_names = roles.flat_map { |r| ["Nombre " + r.name, "Email " + r.name] }

      ["Nombre", "Correo", "Rol", "Fecha de Activación", "Fecha de Desactivación"] + roles_names
    end


    def filter_by_structure(params)
      level_filter = last_level_selected(params)

      users_ids = Structure.find_by(user_id: level_filter).descendants.pluck(:user_id)
      users_ids << level_filter
      users_ids
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
