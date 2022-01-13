# frozen_string_literal: true

class ProjectsImportJob < ApplicationJob
  include ExportExcelErrors
  queue_as :default

  def perform(job_status)
    job_status.add_progress!("Importando proyectos ...")
    file = Tempfile.new([job_status.file_name, ".xlsx"], encoding: "ascii-8bit")
    file.binmode
    excel_rows = []
    columns_with_error = []

    job_status.add_progress!("Leyendo Excel...")
    begin
      file.write(job_status.file.download)
      file.rewind

      book = Roo::Spreadsheet.open(file.path)
      models_sheets = [
                       :Project,
                       :Phase,
                       :CreditScheme,
                       :Period,
                       :Stage,
                       :Lot,
                       :Role,
                       :Permission,
                       :RolePermission,
                       :DocumentSection,
                       :DocumentTemplate,
                       :Step,
                       :StepDocument,
                       :StepRole,
                       :StepRoleDocumentTemplate
                      ]
      begin
        relationships = {}
        models_sheets.each do |model|
          result = build_data_from_sheet(model.to_s, book, job_status, relationships)
          case model
          when :Project
            relationships[:project_relationship] = result[:relationship]
          when :Phase
            relationships[:phase_relationship] = result[:relationship]
          when :CreditScheme
            relationships[:credit_relationship] = result[:relationship]
          when :Stage
            relationships[:stage_relationship] = result[:relationship]
          when :Role
            relationships[:role_relationship] = result[:relationship]
          when :Permission
            relationships[:permission_relationship] = result[:relationship]
          when :DocumentSection
            relationships[:document_section_relationship] = result[:relationship]
          when :DocumentTemplate
            relationships[:document_template_relationship] = result[:relationship]
          when :Step
            relationships[:step_relationship] = result[:relationship]
          when :StepRole
            relationships[:step_role_relationship] = result[:relationship]
          end

          if result[:excel_rows].size > 0
            header_columns = error_headers(model.to_s, send("#{model.to_s.underscore}_attribute_order"))
            header_columns << "Observaciones"
            excel_rows << build_excel_row(header_columns, "")
            excel_rows = excel_rows + result[:excel_rows]
          end
        end
      rescue Roo::HeaderRowNotFoundError => ex
        columns_with_error = JSON.parse(ex.message)
        error_message = "Las siguientes columnas no fueron encontradas en el archivo: #{columns_with_error.join(", ")}."
        job_status.add_progress!(error_message)
        job_status.mark_failed!(error_message)
        job_status.log_error!(ex)
      end

      job_status.add_progress!("Limpiando proceso...")
    ensure
      file.close
      file.unlink
    end

    job_status.file.purge if job_status.file.present?
    (job_status = attach_excel_file(excel_rows, job_status, "Errores")) if excel_rows.size > 0

    if columns_with_error.empty?
      job_status.mark_completed!
    end
  rescue StandardError => e
    job_status.mark_failed!(e.to_s)
    job_status.log_error!(e)
    Bugsnag.notify(e)
  end

  private

    def build_data_from_sheet(model, book, job_status, extra_data = {})
      model_class = model.constantize
      model_underscore = model.underscore
      relationship = {}
      excel_rows = []

      book.sheet(model_class.model_name.human(count: 2)).each_with_index(header(model_class, send("#{model_underscore}_attribute_order"))) do |row, idx|
        next if row[:id] == "UUID" || extra_restrictions(model, row, extra_data)
        item = send("build_#{model_underscore}", row, extra_data)
        job_status.add_progress!("Guardando fila: #{idx}...")
        item.save!
        relationship[row[:id]] = item.id
      rescue ActiveRecord::RecordInvalid => ex
        job_status.add_progress!("Error fila #{idx}: #{ex.message}")
        excel_rows << build_excel_row(row, ex.message)
      end

      { relationship: relationship, excel_rows: excel_rows }
    end

    def extra_restrictions(model, row, extra_data)
      case model
      when Phase.to_s
        !extra_data[:project_relationship].has_key?(row[:project_id])
      when Period.to_s
        !extra_data[:credit_relationship].has_key?(row[:credit_scheme_id])
      when Stage.to_s
        !extra_data[:phase_relationship].has_key?(row[:phase_id]) || !extra_data[:credit_relationship].has_key?(row[:credit_scheme_id])
      when Lot.to_s
        !extra_data[:stage_relationship].has_key?(row[:stage_id])
      when RolePermission.to_s
        !extra_data[:role_relationship].has_key?(row[:role_id]) || !extra_data[:permission_relationship].has_key?(row[:permission_id])
      when DocumentTemplate.to_s
        !extra_data[:document_section_relationship].has_key?(row[:document_section_id])
      when StepDocument.to_s
        !extra_data[:step_relationship].has_key?(row[:step_id]) || !extra_data[:document_template_relationship].has_key?(row[:document_template_id])
      when StepRole.to_s
        !extra_data[:step_relationship].has_key?(row[:step_id]) || !extra_data[:role_relationship].has_key?(row[:role_id])
      when StepRoleDocumentTemplate.to_s
        !extra_data[:step_role_relationship].has_key?(row[:step_role_id]) || !extra_data[:document_template_relationship].has_key?(row[:document_template_id])
      else false
      end
    end

    def header(model_class, attributes)
      header_columns = {}
      attributes.each { |attr| header_columns[attr.to_sym] = (attr == "id" ? "UUID" : model_class.human_attribute_name(attr)) }
      header_columns
    end

    def error_headers(model, attributes)
      model_class = model.constantize
      header_columns = []
      attributes.each { |attr| header_columns << (attr == "id" ? "UUID" : model_class.human_attribute_name(attr)) }
      header_columns
    end

    def build_project(row, extra_data)
      project = Project.new(row.except(:id))
      project
    end

    def build_phase(row, extra_data)
      phase = Phase.new(row.except(:id))
      phase.project_id = extra_data[:project_relationship][row[:project_id]]
      phase
    end

    def build_credit_scheme(row, extra_data)
      credit = CreditScheme.new(row.except(:id))
      credit
    end

    def build_period(row, extra_data)
      period = Period.new(row.except(:id))
      period.credit_scheme_id = extra_data[:credit_relationship][row[:credit_scheme_id]]
      period
    end

    def build_stage(row, extra_data)
      stage = Stage.new(row.except(:id))
      stage.phase_id = extra_data[:phase_relationship][row[:phase_id]]
      stage.credit_scheme_id = extra_data[:credit_relationship][row[:credit_scheme_id]]
      stage
    end

    def build_lot(row, extra_data)
      lot = Lot.new(row.except(:id))
      lot.stage_id = extra_data[:stage_relationship][row[:stage_id]]
      lot.status = Lot::STATUS[:FOR_SALE]
      lot
    end

    # Use case:
    # 1 .- If file UUID is nil then it doesn't create record
    # 2 .- If file UUID does not exist in Database then create record and its relationships
    # 3 .- If file UUID exist in Database and it isn't deleted then the record and its relationships are updated
    # 4 .- If file UUID exist in DB and it is deleted then then create record and its relationships (It is considered as not existing)
    def build_role(row, extra_data)
      role = Role.with_deleted.find_or_initialize_by(id: row[:id])
      role.assign_attributes(row.except(:id)) if !role.deleted?
      role = Role.new(row.except(:id)) if role.deleted?
      role
    end

    def build_permission(row, extra_data)
      per = Permission.find_or_initialize_by(id: row[:id])
      per.assign_attributes(row.except(:id))
      per
    end

    # The relationship is checked instead of the UUID to avoid adding repeating relationships.
    def build_role_permission(row, extra_data)
      role_per = RolePermission.find_or_initialize_by(role_id: extra_data[:role_relationship][row[:role_id]],
                                                      permission_id: extra_data[:permission_relationship][row[:permission_id]])
      role_per
    end

    def build_document_section(row, extra_data)
      section = DocumentSection.find_or_initialize_by(id: row[:id])
      section.assign_attributes(row.except(:id))
      section
    end

    def build_document_template(row, extra_data)
      template = DocumentTemplate.find_or_initialize_by(id: row[:id])
      template.assign_attributes(row.except(:id, :document_section_id))
      template.document_section_id = extra_data[:document_section_relationship][row[:document_section_id]]
      template
    end

    def build_step(row, extra_data)
      step = Step.with_deleted.find_or_initialize_by(id: row[:id])
      step.assign_attributes(row.except(:id)) if !step.deleted?
      step = Step.new(row.except(:id)) if step.deleted?
      step
    end

    def build_step_document(row, extra_data)
      step_document = StepDocument.find_or_initialize_by(step_id: extra_data[:step_relationship][row[:step_id]],
                                                         document_template_id: extra_data[:document_template_relationship][row[:document_template_id]])
      step_document.assign_attributes(row.except(:id, :step_id, :document_template_id))
      step_document
    end

    def build_step_role(row, extra_data)
      step_role = StepRole.find_or_initialize_by(step_id: extra_data[:step_relationship][row[:step_id]],
                                                 role_id: extra_data[:role_relationship][row[:role_id]]
                                                )
      step_role.assign_attributes(row.except(:id, :step_id, :role_id))
      step_role
    end

    def build_step_role_document_template(row, extra_data)
      step_template = StepRoleDocumentTemplate
                      .find_or_initialize_by(step_role_id: extra_data[:step_role_relationship][row[:step_role_id]],
                                             document_template_id: extra_data[:document_template_relationship][row[:document_template_id]]
                                            )
      step_template.assign_attributes(row.except(:id, :step_role_id, :document_template_id))
      step_template
    end


    def excel_header
      []
    end

    def project_attribute_order
      [
        "name",
        "reference",
        "quotation",
        "phone",
        "email",
        "currency",
        "project_entity_name",
        "phase_entity_name",
        "stage_entity_name",
        "lot_entity_name",
        "id"
      ]
    end

    def phase_attribute_order
      [
        "name",
        "start_date",
        "project_id",
        "reference",
        "order",
        "id"
      ]
    end

    def credit_scheme_attribute_order
      [
        "name",
        "initial_payment_active",
        "independent_initial_payment",
        "initial_payment_editable",
        "first_payment",
        "initial_payment",
        "relative_down_payment",
        "down_payment_editable",
        "second_payment",
        "min_down_payment",
        "start_installments",
        "max_finance",
        "lock_payment",
        "min_capital_payment",
        "min_down_payment_advance",
        "max_grace_months",
        "max_delay_payments",
        "compound_interest",
        "relative_discount",
        "expire_months",
        "show_rate",
        "show_price",
        "immediate_extra_months",
        "max_percent_immediate_lots_sold",
        "id",
        "status"
      ]
    end

    def period_attribute_order
      [
        "payments",
        "interest",
        "order",
        "credit_scheme_id",
        "id"
      ]
    end

    def stage_attribute_order
      [
        "phase_id",
        "name",
        "show_full_name",
        "reference",
        "stage_type",
        "enterprise_id",
        "price",
        "release_date",
        "delivery_date",
        "payment_receptor_emails",
        "credit_scheme_id",
        "active_messages",
        "active_mails",
        "is_expirable",
        "active_commissions",
        "opening_commission",
        "max_commission_amount",
        "initial_payment_expiration",
        "down_payment_expiration",
        "sudden_death",
        "lock_seller_period",
        "payment_expiration",
        "phase_description_title",
        "stage_description_title",
        "lot_description_title",
        "lot_description",
        "observations",
        "receipt_observations",
        "purchase_conditions",
        "id",
        "min_down_payment",
        "order",
        "max_finance",
        "first_payment",
        "start_installments",
        "min_capital_payment",
        "payment_email",
        "lock_payment",
        "credit_scheme_id",
        "immediate_extra_months",
        "max_percent_immediate_lots_sold",
        "min_down_payment_advance",
        "sort",
        "active_annexes",
        "start_date_by",
        "show_price",
        "show_rate",
        "max_grace_months",
        "max_delay_payments",
        "relative_discount"
      ]
    end

    def lot_attribute_order
      [
        "rid",
        "name",
        "number",
        "label",
        "depth",
        "front",
        "area",
        "price",
        "fixed_price",
        "planking",
        "folio",
        "undivided",
        "color",
        "north",
        "adjoining_north",
        "south",
        "adjoining_south",
        "east",
        "adjoining_east",
        "west",
        "adjoining_west",
        "id",
        "stage_id",
        "status",
        "description"
      ]
    end

    def document_section_attribute_order
      [
        "name",
        "action",
        "order",
        "id",
      ]
    end

    def document_template_attribute_order
      [
        "name",
        "document_section_id",
        "formats",
        "requires_approval",
        "visible",
        "copy_to_all",
        "id",
        "permissions",
        "key",
        "action",
        "order"
      ]
    end

    def step_document_attribute_order
      [
        "step_id",
        "document_template_id",
        "required",
        "id"
      ]
    end

    def step_role_document_template_attribute_order
      [
        "step_role_id",
        "document_template_id",
        "readable",
        "editable",
        "uploadable",
        "destroyable",
        "id"
      ]
    end

    def step_role_attribute_order
      [
        "step_id",
        "role_id",
        "update_financial",
        "update_coowners",
        "can_cancel",
        "can_approve",
        "can_reject",
        "visible",
        "can_comment",
        "can_make_installments",
        "can_manage_reminders",
        "can_add_folder_user",
        "can_edit_folder_user",
        "can_remove_folder_user",
        "can_send_to_sign_purchase_promise",
        "can_send_to_cancel_sign_purchase_promise",
        "can_resend_sign_files",
        "send_by_whatsapp",
        "send_by_email",
        "copy_to_clipboard",
        "id"
      ]
    end

    def step_attribute_order
      [
        "name",
        "reject_step_id",
        "hubspot_id",
        "installments_step",
        "lot_status",
        "folders_expires",
        "folder_user_concept_id",
        "id",
        "blocked",
        "folders_count"
      ]
    end

    def role_attribute_order
      [
        "name",
        "key",
        "is_evo",
        "hidden",
        "id"
      ]
    end

    def permission_attribute_order
      [
        "name",
        "subject_class",
        "action",
        "description",
        "hidden",
        "id"
      ]
    end

    def role_permission_attribute_order
      [
        "role_id",
        "permission_id",
        "id"
      ]
    end
end
