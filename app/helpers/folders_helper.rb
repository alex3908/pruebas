# frozen_string_literal: true

require "action_view"

include ActionView::Helpers::DateHelper

module FoldersHelper
  def installment_table_message(paid: false, overdue: false, next_overdue: false, is_multiple: false)
    return "PAGADO" if paid
    return "SALDO VENCIDO" if overdue
    return "SALDO PROXIMO A VENCER" if next_overdue
    return "ACEPTA ABONOS MÚLTIPLES" if is_multiple
    "PAGO PROXIMO"
  end

  def installment_table_class(paid: false, overdue: false, next_overdue: false, is_multiple: false)
    return "multiple-row" if is_multiple
    return "primary-row" if paid
    return "danger-row" if overdue
    return "warning-row" if next_overdue
    "normal-row"
  end

  def installment_overdue_days(overdue, today, date)
    overdue ? "Atrasado #{(today - date).to_i} dias" : ""
  end

  def verify_documents(folder, next_step = nil)
    missing_documents(folder, next_step).empty?
  end

  def missing_documents(folder, next_step = nil)
    required_documents(folder, next_step).select { |doc| doc[:missing?] }
  end

  def required_documents(folder, next_step = nil)
    docs = Array.new
    next_step ||= Step.first_step

    folder.documents.includes(:document_template).each do |document|
      step_document = document.document_template.step_documents.find_by(step: next_step) if document.document_template.present?
      docs << { name: document.document_template.name, missing?: !document.latest_file_version.present? } if step_document.present? && step_document.required?
    end
    folder.client.documents.each do |document|
      step_document = document.document_template.step_documents.find_by(step: next_step) if document.document_template.present?
      docs << { name: document.document_template.name, missing?: !document.latest_file_version.present? } if step_document.present? && step_document.required?
    end

    docs
  end

  def can_download?(downloadable_files_ids, file_name)
    return false if downloadable_files_ids.nil?

    downloadable_files_ids.each do |downloadable_file_id|
      return true if DownloadableFile::FILE_NAMES.keys.to_a[downloadable_file_id] == file_name
    end

    false
  end

  def ready_to_download?(folder, contract, stage, lot, downloadable_files_ids)
    folder.ready? && (contract.present? && can_download?(downloadable_files_ids, :purchase_promise) || can_download?(downloadable_files_ids, :purchase_promise_attached)) ||
    stage.active_annexes && (can_download?(downloadable_files_ids, :annexe_1) || can_download?(downloadable_files_ids, :annexe_2) || can_download?(downloadable_files_ids, :annexe_3)) ||
    can_download?(downloadable_files_ids, :amortization_cover) ||
    lot.chepina.attached? ||
    can_download?(downloadable_files_ids, :deposit_format) ||
    can_download?(downloadable_files_ids, :down_payment_receipt) ||
    can_download?(downloadable_files_ids, :down_payment_receipt) && (folder.payment_scheme.complement_payment > 0) ||
    can_download?(downloadable_files_ids, :purchase_conditions) ||
    can_download?(downloadable_files_ids, :amortization_table) ||
    can_download?(downloadable_files_ids, :promissory_note)
  end

  def unavailable_files_button
    "#{"Archivos
    #{tag.i(class: "fa fa-info-circle",
    "aria-hidden": "true",
    "data-toggle": "tooltip",
    "data-placement": "top",
    "title": "Los archivos aún no están listos")}"}".html_safe
  end

  def can_pay_on_this_step(folder, can_make_installments_on_step)
    folder.active? && folder.step.installments_step && can_make_installments_on_step
  end

  def approved_label_result(approval)
    if approval.present? && !approval.unchecked?
      user = approval&.approved_by&.label
      reason = approval.comment
      if approval.approved?
        "Aprobado por #{user}"
      elsif approval.rejected?
        "Rechazado por #{user}: #{reason}"
      end
    else
      "En Revisión"
    end
  end

  def get_folders(params:, sort_column: "folders.created_at", sort_direction: "desc", with_hidden: false)
    params = params.merge(with_hidden: with_hidden)

    if can?(:see_all, Folder)
      Folder.all.set_params(params, sort_column, sort_direction)
    elsif current_user.structure.present? || can?(:reserve, :quote)
      current_user.folders.set_params(params, sort_column, sort_direction)
    else
      hidden_folders = []
      hidden_folders = [Folder::STATUS[:EXPIRED], Folder::STATUS[:CANCELED]] if can?(:view_hidden, Folder)
      steps_ids = Step.joins(:step_roles)
                      .where("step_roles.role_id = (?) AND step_roles.visible IS true", current_user.role_id)
                      .pluck(:id)
      Folder.where("step_id IN (?) OR folders.status IN (?)", steps_ids, hidden_folders).set_params(params, sort_column, sort_direction)
    end
  end

  def annexe_1_body(project, phase, stage)
    phase = Phase.includes(blueprint: { blueprint_stages: :stage }).find_by(id: phase.id)

    if phase.blueprint
      blueprint_phase = phase.blueprint_document(stage, self).render_to_string(layout: false)
    end
    render_to_string("folders/files/annexe_1.html.erb", layout: "pdf", locals: { blueprint_phase: blueprint_phase })
  end

  def annexe_2_body(project, phase, stage, lot)
    stage = Stage.includes(blueprint: [ blueprint_lots: :lot, svg_file_attachment: :blob ]).find_by(id: stage.id)
    if stage.blueprint
      blueprint_stage = stage.blueprint_document(lot, self).render_to_string(layout: false)
    end
    render_to_string("folders/files/annexe_2.html.erb", layout: "pdf", locals: { blueprint_stage: blueprint_stage })
  end

  def annexe_3_body(project, phase, stage, lot)
    Annexe_3.new(project, phase, stage, lot).render_to_string(layout: "pdf")
  end

  def show_document_section(section, folder)
    if folder.payment_scheme.down_payment_paid && (section.action == "down_payment" || section.action == "initial_payment")
      return false
    elsif folder.payment_scheme.opening_commission == 0 && section.action == "commission"
      return false
    end

    true
  end

  def show_document_input(document, folder)
    if document.document_template.try(:action) == "initial_payment_complement" && folder.payment_scheme.complement_payment == 0
      return false
    end

    true
  end

  def section_with_visible_documents(folder, section)
    # Has at least one document and that document is visible
    folder.documents.on_this_section(section).any? && folder.documents.on_this_section(section).inject(false) { |prev, current| prev || current.document_template.visible? }
  end

  def time_in_step(folder, only_time = false)
    time = distance_of_time_in_words(Time.zone.now, folder.step_logs.last.moved_at, { accumulate_on: :days, highest_measure_only: true })
    only_time ? time : "Lleva #{time} en este paso"
  end

  def operation_time(folder)
    if folder.approved_date.nil?
      distance_of_time_in_words(Time.zone.now, folder.calc_date, { accumulate_on: :days, highest_measure_only: true })
    else
      distance_of_time_in_words(folder.approved_date, folder.calc_date, { accumulate_on: :days, highest_measure_only: true })
    end
  end

  def additional_concept_options(folder, stage)
    stage.additional_concepts.active.map { |concept|
      next if folder.is_concept_paid?(concept)
      [concept.name, { data: { type: concept.amount_type, amount: concept.amount } }, concept.id]
    }
  end

  def title_for_missing_tags(tags_without_value)
    missing_variable_name = tags_without_value.map(&:inspect).join(", ")
    "Hacen falta #{missing_variable_name} en el contrato"
  end

  def subordinate_tag(role, parameters, style_class = "col-md-6 col-lg-3 mb-3")
    subordinate = role&.next
    return "" unless subordinate.present?

    template = content_tag :div, id: "#{subordinate.key}-container", class: "#{style_class} #{ "d-none" unless parameters["#{role&.key}_node"].present? }" do
      subordinate_label_tag(subordinate) +
      subordinate_select_tag(subordinate, parameters, role&.key)
    end

    template << subordinate_tag(subordinate, parameters, style_class)
  end

  def subordinate_label_tag(subordinate)
    content_tag :label, for: "#{subordinate.key}_node" do
      "Buscar por #{subordinate&.name&.downcase}:"
    end
  end

  def subordinate_select_tag(subordinate, parameters, parent_role = nil)
    node_key = "#{subordinate.key}_node"
    next_role = subordinate.next

    content_tag "select", subordinate_options(node_key, parameters, parent_role), id: node_key, name: node_key, class: "form-control search-subordinates", include_blank: "Todos", data: { key: subordinate.key, child: next_role&.key  }
  end

  def subordinate_options(node_key, parameters, parent_role)
    return [] unless parameters["#{parent_role}_node"].present?

    subordinates = User.find_by(id: parameters["#{parent_role}_node"]).subordinates

    options_for_select(subordinates.map { |sub| [sub[:name], sub[:id]] }, selected: parameters[node_key].to_i)
  end

  def folder_ready_for_date(folder)
    approval_step_id = Setting.find_by(key: "approval_step_id").try(:convert)
    approval_step = Step.find_by_id(approval_step_id) || Step.last_step

    folder.active? && (folder.step.order >= approval_step.order)
  end

  def completed_sales(folders)
    folders&.where.not(approved_date: nil).size
  end
end
