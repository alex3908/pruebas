# frozen_string_literal: true

require "caxlsx"

class UsersKpiReportJob < ApplicationJob
  queue_as :low_priority

  def perform(status, params)
    status.add_progress!("Generando reporte...")
    status.add_progress!("Creando hoja de cálculo...")

    users = User.all

    structure_filter = filter_by_structure(params) unless last_level_selected(params).nil?

    users = users.where(id: structure_filter) if structure_filter.present?
    roles = Role.evo_structure

    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "KPI") do |sheet|
          sheet.add_row generate_header(roles)
          users.each_with_index do |user, idx|
            sheet.add_row(generate_row(user, roles, params))
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
    def generate_row(user, roles, params)
      row = Array.new

      folders = user.folders.order(id: :asc)
      structure = user.structure

      role_level = user&.role&.level
      roles_structure = roles.map { |role| [structure&.path&.at_depth(role.level)&.first, role.level] }
      roles_structure = roles_structure.map do |role_structure|
        if role_level.present? && role_structure.second <= role_level
          role_structure[1] = true
        else
          role_structure[1] = false
        end
        role_structure
      end

      if params[:from_date].present? && params[:to_date].present?
        folders = folders.where(start_date: params[:from_date].to_date..params[:to_date].to_date)
        dates_between = (params[:from_date].to_date..params[:to_date].to_date).to_a
      else
        now = Time.zone.now.to_date
        dates_between = (now..now).to_a

        if folders.size > 0
          start_date = folders.first.calc_date.to_date
          end_date = folders.last.calc_date.to_date
          dates_between = (start_date..end_date).to_a
        end
      end

      active_folders = folders.where(status: :active)

      salesmen = structure.present? ? User.where(id: structure.descendants.pluck(:user_id)) : nil
      total_folders_ten_percent = count_down_payment_percentage(folders, 10)
      total_folders_five_percent = count_down_payment_percentage(folders, 5)

      diferred_sales = active_folders.inject(0) { |sum, folder| sum + (folder.has_differed_downpayments && folder.has_down_payment_overdue ? 1 : 0) }
      folders_count = active_folders.size
      average_days_without_sell = folders_count > 0 ? (active_folders.inject(0) { |sum, folder| sum + (dates_between.include?(folder.calc_date.to_date) ? 1 : 0) } / folders_count) : 0
      average_days_reserve_to_finalized = folders_count > 0 ? (folders.where.not(approved_date: nil).inject(0) { |sum, folder| sum + (folder.approved_date - folder.calc_date.to_date).to_i } / folders_count) : 0
      average_salesman_sales = salesmen.present? ? salesmen.inject(0) { |sum, salesman| sum + (salesman.folders.where(status: :active).any? ? 1 : 0) } : 0

      row << user.label
      row << user.role.name
      row << active_folders.where(step: Step.first_step).size
      row << active_folders.where.not(approved_date: nil).size
      row << active_folders.where(approved_date: nil).size
      row << folders.where(status: :canceled).size
      row << average_days_without_sell
      row << average_days_reserve_to_finalized
      row << salesmen&.count.presence || 0
      row << average_salesman_sales
      row << total_folders_ten_percent
      row << total_folders_five_percent
      row << diferred_sales

      roles_structure.each do |rs|
        if !rs.first.nil? && rs.first.user.present?
          row << rs.first.user.label
          row << rs.first.user.email
        elsif rs.second
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
      roles_names = roles.flat_map { |r| ["NOMBRE " + r.name&.upcase, "EMAIL " + r.name&.upcase] }

      [
        "NOMBRE DE USUARIO",
        "ROL",
        "NUMERO DE APARTADOS",
        "NUMERO DE VENTAS CONCRETADAS",
        "NUMERO DE VENTAS PENDIENTES POR CONCRETAR",
        "NUMERO DE VENTAS CANCELADAS",
        "PROMEDIO DE DÍAS SIN VENDER",
        "PROMEDIO DE DÍAS DE OPERACIÓN DE APARTADO A CONCRETADO",
        "NUMERO DE VENDEDORES VENDIENDO",
        "PORCENTAJE DE VENDEDORES/VENTAS",
        "VENTAS CON ENGANCHE AL 10%",
        "VENTAS CON ENGANCHE AL 5%",
        "VENTAS DIFERIDAS"
      ] + roles_names
    end

    def count_down_payment_percentage(folders, percentage)
      folders.inject(0) { |sum, folder| sum + ((folder.down_payment_percentage * 100) == percentage.to_i ? 1 : 0) }
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
