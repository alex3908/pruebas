# frozen_string_literal: true

require "caxlsx"

class ProjectsExportJob < ApplicationJob
  queue_as :low_priority

  def perform(status)
    status.add_progress!("Generando reporte de todo el ambiente ...")
    status.add_progress!("Creando hoja de cálculo...")
    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")
      status.add_progress!("Guardando hoja de cálculo...")

      sheets_models = [ "Project",
                        "Phase",
                        "CreditScheme",
                        "Period",
                        "Stage",
                        "Lot",
                        "Role",
                        "Permission",
                        "RolePermission",
                        "DocumentSection",
                        "DocumentTemplate",
                        "Step",
                        "StepDocument",
                        "StepRole",
                        "StepRoleDocumentTemplate"
                      ]

      Axlsx::Package.new do |xlsx_package|
        wookbook = xlsx_package.workbook
        sheets_models.each { |model| build_sheet_from_model(model, wookbook) }
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

    def build_sheet_from_model(model, workbook)
      model_class = model.constantize
      model_underscore = model.underscore
      workbook.add_worksheet(name: model_class.model_name.human(count: 2)) do |sheet|
        model_attribute_order = send("#{model_underscore}_attribute_order")
        sheet.add_row(header(model_class, model_attribute_order))
        model_class.all.order("id asc").each { |item| sheet.add_row(generate_row(item, model_attribute_order)) }
      end
    end

    def header(model_class, attributes)
      header_columns = []
      attributes.each { |attr| header_columns << (attr == "id" ? "UUID" : model_class.human_attribute_name(attr)) }
      header_columns
    end

    def generate_row(model_instance, attributes)
      row = []
      attributes.each { |attr| row << model_instance[attr] }
      row
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
