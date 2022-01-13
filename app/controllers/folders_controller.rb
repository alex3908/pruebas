# frozen_string_literal: true

include ActionView::Helpers::NumberHelper
include ActionView::Helpers::DateHelper
include ActionView::Helpers::TextHelper

class FoldersController < ApplicationController
  include FolderHandler, FoldersHelper, QuotationsHelper, DiscountsHelper, CommissionsHelper, ContractsHelper, EvaluationsHelper, DocumentsHelper, EntityNamesConcern, SignatureServiceConcern
  load_and_authorize_resource except: [:accept, :reject, :soft_reject, :cancel, :update_files, :pay_online, :concept_details, :toggle_reminders, :send_purchase_promise_to_sign, :cancel_purchase_promise_to_sign, :down_payment_receipt, :amortization_table, :amortization_cover, :purchase_conditions, :annexe_1, :annexe_2, :annexe_3, :purchase_promise_attached, :promissory_note, :purchase_promise_only, :purchase_promise, :deposit_format]
  load_resource only: [:pay_online, :concept_details, :toggle_reminders]
  before_action :set_folder, :set_project_entity_names_by_folder, except: [:index, :import, :export, :export_overdue_balances, :export_balances_close_to_due, :pay_online, :concept_details]
  before_action :generate, only: [:show, :deposit_format, :down_payment_receipt, :reserve_receipt, :amortization_table, :amortization_cover, :purchase_conditions, :purchase_promise_attached, :purchase_promise, :promissory_note, :set_contract, :send_documents_to_sign]
  before_action :set_contract, only: [:show, :purchase_promise]
  before_action :slice_amr, only: [:amortization_table, :amortization_cover, :purchase_conditions, :purchase_promise_attached]
  before_action :verify_access, except: [:pay_online, :concept_details, :cancel]
  before_action :set_installments, except: [:cancel]
  before_action :set_totals, only: [:show, :promissory_note, :amortization_table]
  before_action :set_last_rejected_evaluation_folders, :set_folder_user_concepts, only: :show
  helper_method :translate_date_by_string, :get_translate, :get_status, :get_buyer, :sort_column, :sort_direction, :can_cancel_folder?
  before_action :payment_modal_permissions, only: [:payment_modal_info, :show]
  before_action :total_cash_flow, :show_cash_flows, eonly: [:new, :edit, :update, :create]
  skip_before_action :verify_authenticity_token

  def index
    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    @projects = Project.includes(phases: :stages).order(id: :asc)
    @branches = Branch.all.order(id: :asc)
    @steps = Step.all

    if current_user.structure.present? && current_user.role.level.present?
      @first_evo_searcher = current_user.structure.children
      @subordinate = current_user.role.next
    else
      level = Role.root
      @first_evo_searcher = Structure.where(role_id: level&.id)
      @subordinate = level
    end

    @first_evo_searcher = @first_evo_searcher.where.not(user_id: nil)
    @filter_path = folders_path

    if cannot?(:see_all_branches, Folder)
      params[:branch] = current_user.branch_id
    end

    @folders = get_folders(params: params, sort_column: sort_column, sort_direction: sort_direction)
    @folders = @folders.paginate(page: params[:page], per_page: @per_page)

    respond_to do |format|
      format.html
    end
  end

  def export
    folders = folder_report_filter(current_user, params)
    download_limit = Setting.find_by(key: "download_limit").try(:convert)
    for_reports_view = params[:for_reports_view] == true.to_s

    if folders.size <= download_limit
      if params[:template] == true.to_s
        job_status = JobStatus.create!(
          name: "Plantilla de importación de expedientes - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}",
          user: current_user,
          status: "pending"
        )
        job = FolderImportTemplateJob.perform_later(job_status, folders)
        job_status.update(job_id: job.provider_job_id)
      else
        job_status = JobStatus.create!(
          name: "Reporte de expedientes - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}",
          user: current_user,
          status: "pending"
        )
        job = FolderReportJob.perform_later(current_user.id, job_status, folders, for_reports_view)
        job_status.update(job_id: job.provider_job_id)
      end
    end

    respond_to do |format|
      format.json do
        if folders.size <= download_limit
          render job_status
        else
          render json: { error: :limit_reached }
        end
      end
    end
  end

  def export_overdue_balances
    raise CanCan::AccessDenied.new("No tienes permisos para generar este reporte") unless can?(:overdue_balances, :report)
    folders = Folder.where(step: Step.last_step).search(params).pluck(:id)

    job_status = JobStatus.create!(name: "Reporte de saldos vencidos - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = OverdueBalanceReportJob.perform_later(job_status, folders)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def export_balances_close_to_due
    raise CanCan::AccessDenied.new("No tienes permisos para generar este reporte") unless can?(:balances_close_to_due, :report)
    folders = Folder.where(step: Step.last_step).search(params).pluck(:id)

    job_status = JobStatus.create!(name: "Reporte de saldos por vencer - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = BalanceCloseToDueReportJob.perform_later(job_status, folders)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def show
    @can_see_folder_users = @step_role&.can_add_folder_user? || @step_role&.can_edit_folder_user? || @step_role&.can_remove_folder_user? ||
    can?(:see_folder_users, Folder) || can?(:create, FolderUser) || can?(:update, FolderUser) || can?(:destroy, FolderUser) ||
    (can?(:create_only_hidden, FolderUser) || can?(:update_only_hidden, FolderUser) || can?(:destroy_only_hidden, FolderUser)) && @folder.not_active?
    @ready_for_sign = false
    @cash_backs = CashBack.left_joins(cash_back_flows: :cash_flow).where("cash_flows.folder_id = :folder_id OR cash_backs.exclusive_folder_id = :folder_id", folder_id: @folder.id).order(created_at: :desc).uniq
    @can_reassign_client = @step_role&.can_reassign_client?
    @can_reassign_seller = @step_role&.can_reassign_seller?

    # You can see the promise if you have the permission or if the folder is set as ready, and you have the permission to see it after ready
    @can_pay_online = @stage.enterprise.online_payment_services.available.any?

    if can?(:create, FolderUser)
      @folder_users = User.active.order(created_at: :desc)
    end

    # There is an active support sale if there is any existing support sale that is not canceled
    @active_support_sale = @folder.support_sales.active.take
    @can_request_support = can?(:request_support, Folder) && !(@folder.finished?)
    @support_vicedirectors = User.where(role: Role.find_by_key("vice_director")) unless @active_support_sale.present?

    if can?(:see_binnacle, Folder)
      @logs_folder = Log.where(element: "folder", element_id: @folder.id).includes(:user)
      @logs_scheme = Log.where(element: "scheme", element_id: @folder.payment_scheme.id).includes(:user)
      @logs_users = Log.where(element: "folder_user", element_id: @folder.folder_users.with_deleted.pluck(:id)).includes(:user)
    end

    if @can_reassign_seller
      @sellers = current_user.structure.present? ? User.where(id: current_user.structure.subtree.pluck(:user_id)).active.can_reserve : User.active.can_reserve.order(created_at: :desc)
    end

    @document_sections = DocumentSection.all.order(:order)

    expiration_configured = @folder.stage.initial_payment_expiration.present? && @folder.stage.down_payment_expiration.present?
    if !@folder.expired? && @folder&.step&.folders_expires && @folder.expiration_date.nil? && expiration_configured
      if !@folder.documents.with_custom_action("initial_payment").take.try(:attached?)
        @expiration_date = @folder.calc_date.to_time + @folder.stage.initial_payment_expiration.hours
        @expiration_date += @folder.initial_payment_sudden_death.hours if @folder.initial_payment_sudden_death.present?
        @expiration_reason = "Comprobante de apartado"
      elsif !@folder.documents.with_custom_action("down_payment").take.try(:attached?)
        @expiration_date = @folder.calc_date.to_time + @folder.stage.down_payment_expiration.hours
        @expiration_date += @folder.down_payment_sudden_death.hours if @folder.down_payment_sudden_death.present?
        @expiration_reason = "Comprobante de enganche"
      end
    end

    update_digital_signature_status(@folder.get_last_digital_signature) if @folder&.has_pending_purchase_promise_signatures?


    @tags_without_value = @folder.ruled_contract.present? ? @folder&.purchase_promise_document.tags_without_value : []

    @can_show_signatures_section = @folder.ruled_contract.present? && (@step_role&.can_send_to_sign_purchase_promise? || @step_role&.can_send_to_cancel_sign_purchase_promise?)

    @ready_for_sign = @step_role&.can_send_to_sign_purchase_promise? && @folder&.has_manual_signature_services? &&
                      @folder&.ruled_contract.present?


    @confirmed_emails = @folder&.confirmed_client_email?

    @digital_signature_logs = DigitalSignatureLog.where(digital_signature: @folder.digital_signature_ids).order(date: :asc)
  end

  def toggle_reminders
    if @step_role&.can_manage_reminders?
      @folder.toggle!(:reminders_enabled)
    else
      flash[:error] = "No tienes permiso para realizar esta acción."
    end
  ensure
    head :ok
  end

  def toggle_invoice
    if can_pay_on_this_step(@folder, @step_role&.can_make_installments?)
      @folder.toggle!(:invoice_enabled)
    else
      flash[:error] = "No tienes permiso para realizar esta acción."
    end
  ensure
    head :ok
  end

  def extend
    type = params["type"]
    if type == "initial_payment"
      @folder.initial_payment_sudden_death = @folder.stage.sudden_death
      file = "comprobante de apartado"
    elsif type == "down_payment"
      @folder.down_payment_sudden_death = @folder.stage.sudden_death
      file = "comprobante de enganche"
    end

    if @folder.save
      redirect_to folder_path(@folder), success: "Se ha extendido el tiempo para cargar el #{file}."
    else
      redirect_to folder_path(@folder), error: "Hubo un error al extender el tiempo."
    end
  end

  def reassign_seller
    raise CanCan::AccessDenied.new("No tiene permisos para reasignar este propietario") unless @step_role&.can_reassign_seller?

    if @folder.update(user_id: params[:folder][:user])
      redirect_to folder_path(@folder), success: "El propietario se ha actualizado correctamente."
    else
      redirect_to folder_path(@folder), error: "Hubo un problema al actualizar el asesor. Por favor inténtalo de nuevo."
    end
  end

  def reassign_client
    raise CanCan::AccessDenied.new("No tiene permisos para reasignar este cliente") unless @step_role&.can_reassign_client?

    if @folder.update(client_id: params[:folder][:client])
      redirect_to folder_path(@folder), success: "El cliente se ha sido actualizado correctamente."
    else
      redirect_to folder_path(@folder), error: "Hubo un problema al actualizar el cliente. Por favor inténtalo de nuevo."
    end
  end

  def change_buyer
    @folder.buyer = params["buyer"]

    if params["buyer"] == Folder::BUYER[:OWNER] || params["buyer"] == Folder::BUYER[:COOWNER]
      if @folder.save
        redirect_to folder_path(@folder), success: "El tipo de expediente se actualizó correctamente."
      else
        flash[:error] = "Hubo un error al actualizar el expediente."
        redirect_to folder_path(@folder)
      end
    else
      redirect_to folder_path(@folder), alert: "El tipo expediente no existe."
    end
  end

  def add_client
    if @folder.client_2_id.present? && @folder.client_3_id.present? && @folder.client_4_id.present? && @folder.client_5_id.present? && @folder.client_6_id.present?
      redirect_to folder_path(@folder), error: "No es posible agregar más copropietarios a este expediente."
    end

    if @folder.client_2_id.nil?
      @folder.client_2_id = params[:client].to_f
    elsif @folder.client_3_id.nil?
      @folder.client_3_id = params[:client].to_f
    elsif @folder.client_4_id.nil?
      @folder.client_4_id = params[:client].to_f
    elsif @folder.client_5_id.nil?
      @folder.client_5_id = params[:client].to_f
    elsif @folder.client_6_id.nil?
      @folder.client_6_id = params[:client].to_f
    end

    if @folder.save
      redirect_to folder_path(@folder), success: "El copropietario fue agregado correctamente."
    else
      redirect_to folder_path(@folder), error: "Hubo un error al agregar el copropietario, por favor inténtalo de nuevo."
    end
  end

  def remove_client
    @folder.client_2_id = nil if params[:client].to_f == 2
    @folder.client_3_id = nil if params[:client].to_f == 3
    @folder.client_4_id = nil if params[:client].to_f == 4
    @folder.client_5_id = nil if params[:client].to_f == 5
    @folder.client_6_id = nil if params[:client].to_f == 6

    if @folder.save
      redirect_to folder_path(@folder), success: "Copropietario eliminado correctamente."
    else
      redirect_to folder_path(@folder), error: "Hubo un error al eliminar el copropietario. Por favor inténtalo de nuevo."
    end
  end

  def reactivate
    raise CanCan::AccessDenied.new("No tiene permisos para reactivar este expediente") unless can?(:reactivate, Folder) && @folder.expired? && @folder.lot.for_sale?

    if !@folder.reactivate
      redirect_to folder_path(@folder), error: "El expediente no ha podido ser activado"
    elsif @folder.payment_scheme.has_invalid_coupon?
      @folder.payment_scheme.update(coupon: nil)
    elsif @folder.payment_scheme.coupon.present?
      @folder.payment_scheme.coupon.update(usages: @folder.payment_scheme.coupon.usages + 1)
    end

    redirect_to folder_path(@folder), success: "El expediente ha sido activado"
  end

  def update_files
    raise CanCan::AccessDenied.new("No tiene permisos para actualizar los archivos") unless @step_role.present? || @step_role.has_any_document_permission?
    if @folder.update(folder_params)
      redirect_to folder_path(@folder), success: "Se agregaron correctamente los archivos a la carpeta."
    else
      redirect_to folder_path(@folder), error: "Hubo un error al subir los archivos."
    end
  end

  def update
    if @folder.update(folder_params)
      redirect_to folder_path(@folder), success: "Se editó correctamente el expediente."
    else
      redirect_to folder_path(@folder), error: "Hubo un error al editar el expediente."
    end
  end

  def rejectable_file
    respond_to do |format|
      format.html
      format.js
    end
  end

  def deposit_format
    raise CanCan::AccessDenied.new("No tiene permisos para descargar la ficha de depósito") unless can_download?(@downloadable_files_ids, :deposit_format)
    respond_to do |f|
      f.pdf { render_pdf "FICHA DE DEPOSITO", "folders/files/new_format/deposit_format.html.erb" }
      f.html { render file: "folders/files/new_format/deposit_format.html.erb", layout: "pdf.html" } unless Rails.env.production?
    end
  end

  # Files

  def down_payment_receipt
    raise CanCan::AccessDenied.new("No tiene permisos para descargar los recibos") unless can_download?(@downloadable_files_ids, :down_payment_receipt)
    type = params[:type]

    if type == "complement_payment" && @folder.payment_scheme.complement_payment == 0
      type = "initial_payment"
    end

    @key = type
    @with_copy = true
    @with_signature = true
    case type
    when "complement_payment"
      @amount = @folder.payment_scheme.complement_payment
      @title = "RECIBO DE APARTADO"
      @concept = "Complemento de Apartado"
    when "initial_payment"
      @amount = @folder.payment_scheme.lock_payment
      @title = "RECIBO DE APARTADO"
      @concept = "Apartado"
    when "opening_commission"
      @amount = @folder.payment_scheme.opening_commission
      @title = "CUOTA POR APERTURA"
      @concept = "Cuota de apertura"
    else
      @amount = @folder.first_down_payment&.total
      @title = "RECIBO DE ENGANCHE"
      @concept = "Enganche"
    end

    respond_to do |f|
      f.pdf { render_pdf @title, "folders/files/new_format/down_payment_receipt.html.erb" }
      f.html { render file: "folders/files/new_format/down_payment_receipt.html.erb", layout: "pdf.html" } unless Rails.env.production?
    end
  end

  def amortization_table
    raise CanCan::AccessDenied.new("No tiene permisos para descargar la tabla de amortización") unless can_download?(@downloadable_files_ids, :amortization_table)
    amortization_table = @folder.amortization_table_document(true)

    respond_to do |format|
      format.pdf { send_data amortization_table.to_pdf, filename: "amortization_table.pdf", type: "application/pdf", disposition: "inline" }
      format.html { render html: amortization_table.render_to_string } unless Rails.env.production?
    end
  end

  def amortization_cover
    raise CanCan::AccessDenied.new("No tiene permisos para descargar la carátula de amortización") unless can_download?(@downloadable_files_ids, :amortization_cover)
    @show_table = false
    @with_signature = true
    respond_to do |f|
      f.pdf { render_pdf "CARATULA DE AMORTIZACION", "folders/files/new_format/partials/_amortization_cover.html.erb" }
      f.html { render file: "folders/files/new_format/partials/_amortization_cover.html.erb", layout: "pdf.html" } unless Rails.env.production?
    end
  end

  def purchase_conditions
    raise CanCan::AccessDenied.new("No tiene permisos para descargar las condiciones de compra") unless can_download?(@downloadable_files_ids, :purchase_conditions)
    purchase_conditions = @folder.purchase_conditions_document(true, true)

    respond_to do |format|
      format.pdf { send_data purchase_conditions.to_pdf, filename: "purchase_conditions.pdf", type: "application/pdf", disposition: "inline" }
      format.html { render html: purchase_conditions.render_to_string } unless Rails.env.production?
    end
  end

  def annexe_1
    raise CanCan::AccessDenied.new("No tiene permisos para descargar el anexo 1") unless can_download?(@downloadable_files_ids, :annexe_1)
    annexe = Annexe_1.new(@lot.stage, { controller: self })

    respond_to do |format|
      format.pdf { send_data annexe.to_pdf, filename: "annexe_1.pdf", type: "application/pdf", disposition: "inline" }
      format.html { render html: annexe.render_to_string } unless Rails.env.production?
    end
  end

  def annexe_2
    raise CanCan::AccessDenied.new("No tiene permisos para descargar el anexo 2") unless can_download?(@downloadable_files_ids, :annexe_2)
    annexe = Annexe_2.new(@lot, { controller: self })

    respond_to do |format|
      format.pdf { send_data annexe.to_pdf, filename: "annexe_2.pdf", type: "application/pdf", disposition: "inline" }
      format.html { render html: annexe.render_to_string } unless Rails.env.production?
    end
  end

  def annexe_3
    raise CanCan::AccessDenied.new("No tiene permisos para descargar el anexo 3") unless can_download?(@downloadable_files_ids, :annexe_3)
    annexe = Annexe_3.new(@lot, { controller: self })

    respond_to do |format|
      format.pdf { send_data annexe.to_pdf, filename: "annexe_3.pdf", type: "application/pdf", disposition: "inline" }
      format.html { render html: annexe.render_to_string } unless Rails.env.production?
    end
  end

  def purchase_promise_attached
    raise CanCan::AccessDenied.new("No tiene permisos para descargar el anexo PLD") unless can_download?(@downloadable_files_ids, :purchase_promise_attached) && @folder.ready?
    annexe = @folder.annexe_pld_document

    respond_to do |format|
      format.pdf { send_data annexe.to_pdf, filename: "purchase_promise_attached.pdf", type: "application/pdf", disposition: "inline" }
      format.html { render html: annexe.render_to_string } unless Rails.env.production?
    end
  end

  def promissory_note
    raise CanCan::AccessDenied.new("No tiene permisos para descargar el pagaré") unless can_download?(@downloadable_files_ids, :promissory_note)
    @with_margins = true
    @with_page_number = true
    @payment_total = @quotation.amr.inject(0) { |sum, payment| sum + payment[:payment] }
    payments_block = @quotation.amr.each_slice(2).to_a
    @amr = payments_block.map do |block|
      left, right = block.each_slice((block.size / 2.to_f).ceil).to_a
      right.present? ? left.zip(right) : left.zip
    end
    respond_to do |f|
      f.pdf { render_pdf "Pagaré", "folders/files/promissory_note.html.erb" }
      f.html { render file: "folders/files/promissory_note.html.erb", layout: "pdf.html" } unless Rails.env.production?
    end
  end

  def purchase_promise_only
    raise CanCan::AccessDenied.new("No tiene permisos para descargar la promesa de compraventa") unless can_download?(@downloadable_files_ids, :purchase_promise) && @folder.ready?

    purchase_promise = @folder.purchase_promise_document
    respond_to do |format|
      format.html { render html: purchase_promise.render_to_string } unless Rails.env.production?
      format.pdf do
        send_data purchase_promise.to_pdf, filename: "purchase_promise.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def purchase_promise
    raise CanCan::AccessDenied.new("No tiene permisos para acceder a este archivo") unless @folder.ready? && can_download?(@downloadable_files_ids, :purchase_promise) && @folder.ready?
    job_status = JobStatus.create!(name: "Promesa de compraventa Exp #{@folder.id} - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = PurchasePromiseJob.perform_later(@folder.id, job_status)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  # Actions
  def accept
    raise CanCan::AccessDenied.new("No tiene permisos para aceptar este expediente") unless @step_role&.can_approve?

    if @approve_questions.present?
      return unless params.dig(:folder, :answer).present?
      params.dig(:folder, :answer).each do |answer|
        EvaluationFolder.create!(folder: @folder, evaluation_id: answer[0], answer: answer[1], user: current_user) unless answer[1].blank?
      end
    end

    if @folder.next_step.blocked?
      flash[:error] = "El paso destino '#{@folder.next_step.name}' se encuentra bloqueado."
      redirect_to folder_path(@folder)
    elsif @folder.validate_concept && @folder.validate_client_user_concept
      if @folder.approve
        set_automatic_cash_back(current_user, @folder) if @folder.step.is_last_one?
        redirect_to @folder, success: @folder.step.is_last_one? ? "El expediente ha sido aprobado." : "El expediente ha sido enviado a #{@folder.step.name}." if @folder.lot.save
      else
        redirect_to folder_path(@folder), error: "Hubo un problema actualizando el expediente."
      end
    else
      redirect_to folder_path(@folder), alert: "No fue posible mover el expediente ya que es necesario que un #{@folder.concepts_message} este ligado a este paso"
    end
  end

  def reject
    raise CanCan::AccessDenied.new("No tiene permisos rechazar este expediente") unless @step_role&.can_reject?

    if @reject_questions.present?
      return unless params.dig(:folder, :answer).present?
      params.dig(:folder, :answer).each do |answer|
        EvaluationFolder.create!(folder: @folder, evaluation_id: answer[0], answer: answer[1], user: current_user)
      end
    end

    if @folder.reject
      redirect_to folder_path(@folder), success: "El expediente se regresó a #{@folder.step.name}"
    else
      redirect_to folder_path(@folder), error: "Hubo un problema actualizando el expediente."
    end
  end

  def soft_reject
    raise CanCan::AccessDenied.new("No tiene permisos para rechazar este expediente") unless @step_role&.can_soft_reject?

    if @folder.move_back
      redirect_to folder_path(@folder), success: "El expediente se regresó a #{@folder.step.name}"
    else
      redirect_to folder_path(@folder), error: "Hubo un problema al mover el expediente."
    end
  end

  def cancel
    raise CanCan::AccessDenied.new("No tiene permisos para cancelar este expediente") unless can_cancel_folder?
    cancelation_reasons = false

    if @cancel_questions.present?
      return unless params.dig(:folder, :answer).present?

      params.dig(:folder, :answer).each do |answer|
        cancelation_reasons = true if answer[1] == "Si"
      end

      params.dig(:folder, :answer).each do |answer|
        EvaluationFolder.create!(folder: @folder, evaluation_id: answer[0], answer: answer[1], user: current_user)
      end
    end

    can_cancel = @cancel_questions.present? && cancelation_reasons || params.dig(:canceled_description).present?

    if can_cancel && @folder.cancel(params[:canceled_description])
      redirect_to folder_path(@folder), alert: "El expediente ha sido cancelado correctamente."
    elsif !can_cancel
      redirect_to folder_path(@folder), flash: { error: "Debes seleccionar al menos una razón de cancelación." }
    else
      redirect_to folder_path(@folder), flash: { error: "Hubo un error la cancelar tu expediente, por favor intentalo de nuevo." }
    end
  end

  def set_ready_state
    if @folder.update(ready: true)
      redirect_to folder_path(@folder), success: "La promesa de compra venta fue activada correctamente."
    else
      redirect_to folder_path(@folder), flash: { error: "Hubo un error al activar la promesa de compraventa, por favor intentalo de nuevo." }
    end
  end

  # Payment

  def pay_online
    @folder = Folder.includes(lot: [{ stage: [{ phase: :project }] }]).find_by_id!(params[:id])
    @lot = @folder.lot
    @stage = @folder.lot.stage
    @phase = @folder.lot.stage.phase
    @project = @folder.lot.stage.phase.project
    render layout: "online_payments"
  end

  def concept_details
    @folder = Folder.includes(lot: [{ stage: [{ phase: :project }] }]).find(params[:id])
    @clients = @folder.clients
    @lot = @folder.lot
    @stage = Stage.find(@lot.stage_id)
    @phase = Phase.find(@stage.phase_id)
    @project = Project.find(@phase.project_id)
    @online_payment_services = @stage.enterprise.online_payment_services.available
    if params[:concept_key].present?

      case params[:concept_key]
      when "reserve"
        concept = "Pago de apartado de la unidad #{@lot.name} de la #{@project.phase_entity_name} #{@phase.name} de la #{@project.stage_entity_name} #{@stage.name} del #{@project.project_entity_name} #{@project.name}"
        amount = "%.2f" % @folder.payment_scheme.initial_payment
      when "down_payment"
        quote = @folder.generate_quote
        down_payment_amount = quote.down_payment_monthly_payments.second[:payment].to_f
        concept = "Pago de apartado + saldo de enganche de la unidad #{@lot.name} de la #{@project.phase_entity_name} #{@phase.name} de la #{@project.stage_entity_name} #{@stage.name} del #{@project.project_entity_name} #{@project.name}"
        amount = "%.2f" % (@folder.payment_scheme.initial_payment + down_payment_amount)
      when "balance_down"
        quote = @folder.generate_quote
        down_payment_amount = quote.down_payment_monthly_payments.second[:payment].to_f
        concept = "Pago de saldo de enganche de la unidad #{@lot.name} de la #{@project.phase_entity_name} #{@phase.name} de la #{@project.stage_entity_name} #{@stage.name} del #{@project.project_entity_name} #{@project.name}"
        amount = "%.2f" % (down_payment_amount)
      when "reserve_fee"
        concept = "Pago de cuota de apertura de la unidad #{@lot.name} de la #{@project.phase_entity_name} #{@phase.name} de la #{@project.stage_entity_name} #{@stage.name} del #{@project.project_entity_name} #{@project.name}"
        amount = "%.2f" % @folder.payment_scheme.opening_commission.to_f
      else
        concept = nil
        amount = nil
      end

      @payment_details = OpenStruct.new(concept: concept, amount: amount, key: params[:concept_key])
    elsif params[:concept_id].present?
      additional_concept = AdditionalConcept.find(params[:concept_id])
      concept = additional_concept.name
      amount = additional_concept.amount

      @payment_details = OpenStruct.new(concept: concept, amount: amount, additional_concept_id: additional_concept.id, key: :additional_concept)
      @online_payment_services = additional_concept.enterprise.online_payment_services
    end

    @online_payment = @payment_details
    @online_payment[:concept_key] = @online_payment[:key]

    render layout: "online_payments"
  end

  def send_purchase_promise_to_sign
    raise CanCan::AccessDenied.new("No tiene permisos para enviar documentos a firma") unless @step_role&.can_send_to_sign_purchase_promise?
    digital_signature_service = @folder.digital_signature_services.first
    if digital_signature_service.present?
      return redirect_to folder_path(@folder), flash: { error: "No se puede iniciar hay un proceso de firma en curso" } if @folder.has_pending_purchase_promise_signatures?
      if !digital_signature_service.is_automatic
        if digital_signature_service.creator.authorize_bearer["success"]
          PurchasePromiseSignatureServiceJob.perform_later(@folder, digital_signature_service, get_digital_signature(@folder, digital_signature_service))
        else
          raise StandardError.new, "No se puede enviar el documento a firma Usuario o contraseña incorrectos"
        end
      end
    else
      redirect_to folder_path(@folder), flash: { error: "No hay un servicio de firmas para este expediente" }
    end
    redirect_to folder_path(@folder), success: "Se ha iniciado el proceso de firma"

  rescue StandardError => ex
    redirect_to folder_path(@folder), flash: { error: ex.message.to_s }
  end

  def cancel_purchase_promise_to_sign
    raise CanCan::AccessDenied.new("No tiene permisos para cancelar el documento a firmar") unless @step_role&.can_send_to_cancel_sign_purchase_promise?
    digital_signature = @folder.get_last_digital_signature

    return redirect_to folder_path(@folder), alert: "El documento esta en proceso de envio al proveedor de firmas digitales por favor intente mas tarde" if digital_signature.status == DigitalSignature.statuses[:initialized] && cannot?(:force_cancel_digital_signature, Folder)

    last_digital_signature = @folder.get_last_digital_signature

    if last_digital_signature.present?
      if last_digital_signature.update(status: DigitalSignature.statuses[:canceled])
        redirect_to folder_path(@folder), success: "Se ha cancelado el proceso de firma"
      else
        redirect_to folder_path(@folder), alert: last_digital_signature.errors.values.join(",")
      end
    else
      redirect_to folder_path(@folder), flash: { error: "No se encontró del documento" }
    end
  rescue StandardError => ex
    redirect_to folder_path(@folder), flash: { error: ex.message.to_s }
  end

  def send_email_payment_link
    raise CanCan::AccessDenied.new("No tiene permisos para enviar correos") unless @step_role.present? && @step_role&.send_by_email?
    return unless params[:client].present? && params[:type].present?
    client = Client.find(params[:client])
    type = params[:type]
    PaymentLinkMailer.send_payment_link(@folder, client, type).deliver_later

    respond_to do |format|
      format.js { render "send_email_payment_link.js.erb" }
    end
  end

  def payment_modal_info
  end

  def sign_links_modal_info
    @participants = []
    statuses = DigitalSignature.statuses
    digital_signature = DigitalSignature.find_by(id: @folder.get_last_digital_signature)
    active_statuses = [statuses[:sent_to_clients_signature], statuses[:sent_for_signature_of_legal_representatives]]

    if digital_signature.present? && active_statuses.include?(digital_signature.status)
      if params[:recipient_type] == "client"
        @participants = digital_signature.digital_signature_participants.client
      else
        @participants = digital_signature.digital_signature_participants.where(recipient_type: [:representative, :observer])
      end
    end
  end

  def send_sign_link_email
    participant = DigitalSignatureParticipant.find_by(id: params[:participant_id])
    if participant.present?
      DigitalSignatureMailer.send_signature_addresses(@folder, participant).deliver_later
      render json: { message: "Correo enviado", error: false }
    else
      render json: { message: "No se encontró al participante", error: true }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def folder_params
      params.require(:folder).permit(:lot_id, :down_payment, :down_payment_plan, :date, :client_id,
                                     :user_id, :bank_deposit, :federal_cedula, :down_payment_receipt,
                                     :conditions_purchase, :marriage_act, :agree_letter,
                                     :amortization_table, :purchase_promise, :status, :buyer, :client_2_id,
                                     :client_3_id, :client_4_id, :client_5_id, :client_6_id, :last_role,
                                     :start_date, :zero_rate, :promissory_note, :reserve_receipt, :credit_balance,
                                     :bank_deposit_complement, :down_payment_voucher, :contract_id, :commission_receipt,
                                     :approved_date, :commission_voucher, :canceled_description, :step_id, answer: [],
                                     documents_attributes: [:id, file_versions_attributes: [ :id, :file ]])
    end

    def show_cash_flows
      @show_cash_flows = CashFlow.where(folder_id: params[:id], status: "active")
      array = []
      @show_cash_flows.each do |value|
        array.push value.payment_method_id
      end
      @show_payment_method = PaymentMethod.where(id: array)
      @show_payment_method.each { |v| @payment_is_income = v.payment_is_income }
    end

    def total_cash_flow
      @total_income = CashFlow.joins(:payment_method).where(folder_id: params[:id], payment_methods: { payment_is_income: true }).collect(&:amount).sum
    end

    def set_totals
      if @folder.canceled?
        canceled_totals
      else
        active_totals
      end
    end

    def set_folder
      raise CanCan::AccessDenied unless current_user.present?
      @folder = Folder.includes(:payment_scheme, :client, :user, lot: { stage: { phase: :project } }).find(params[:id])
      @step = @folder.step
      @step_role = @folder&.step&.step_roles&.find_by(role: current_user.role)
      @downloadable_files_ids = @step_role&.downloadable_files&.pluck(:document)
      @project = @folder.project
      @phase = @folder.phase
      @stage = @folder.stage
      @lot = @folder.lot
      @payment_scheme = @folder.payment_scheme

      if @folder.active?
        questions = @folder.step.evaluations.active
        @approve_questions = questions.select { |question| question.question_type == Evaluation::EVALUATION_TYPES[:APPROVE] }
        @reject_questions = questions.select { |question| question.question_type == Evaluation::EVALUATION_TYPES[:REJECT] }
        @cancel_questions = questions.select { |question| question.question_type == Evaluation::EVALUATION_TYPES[:CANCEL] }
      elsif
        questions = Evaluation.where(question_type: :cancel).pluck(:id)
        @cancelation_reasons = @folder.evaluation_folders.where("evaluation_id IN (?) AND answer = (?)", questions, "Si")
      end

      @folder_without_active_payments = @folder.installments.includes(:payments).where(payments: { status: :active }).count <= 0
    end

    def set_contract
      @contract = @folder.ruled_contract @quotation
    end

    def get_translate(key)
      attributes = {
          "payment_plan_id" => "Plan de Pagos",
          "discount_id" => "Descuentos",
          "lot_id" => @lot_singular,
          "client_id" => "Cliente",
          "user_id" => "Asesor",
          "status" => "Estado",
          "step_id" => "Paso",
          "buyer" => "Comprador",
          "client_2_id" => "Copropietario 1",
          "client_3_id" => "Copropietario 2",
          "client_4_id" => "Copropietario 3",
          "client_5_id" => "Copropietario 4",
          "client_6_id" => "Copropietario 5",
          "zero_rate" => "Meses sin intereses",
          "start_date" => "Fecha de Inicio",
          "name" => "Nombre del plan",
          "initial_payment" => "Apartado",
          "discount" => "Descuento",
          "total_payments" => "Total de pagos",
          "dfp" => "Diferencia Porcentual",
          "down_payment_finance" => "Financiamiento del enganche",
          "down_payment" => "Enganche",
          "buy_price" => "Precio de compra",
          "online_payment_id" => "Pago con Paypal",
          "down_payment_paid" => "Enganche liquidado",
          "first_payment" => "Inicio del primer pago",
          "formula" => "Formula de la cotización",
          "start_installments" => "Periodos de gracia de la mensualidad",
          "promotion" => "Porcentaje de la promoción",
          "promotion_name" => "Nombre de la promoción",
          "promotion_operation" => "Operación para calculo de promoción",
          "expiration_date" => "Fecha de expiración",
          "credit_scheme_id" => "Esquema de Crédito",
          "lock_payment" => "Complemento",
          "ready" => "Promesa de venta activa",
          "contract_id" => "Contrato personalizado",
          "immediate_extra_months" => "Construcción inmediata",
          "opening_commission" => "Comisión por apertura",
          "is_commissionable" => "Expediente comisionable",
          "canceled_description" => "Razón de cancelación",
          "canceled_by" => "Cancelado por",
          "canceled_date" => "Fecha de cancelación",
          "percentage" => "Porcentaje de comisión",
          "amount" => "Monto de comisión",
          "deleted_at" => "Fecha de eliminación",
          "second_payment" => "Fecha límite para el pago de enganche",
          "role_id" => "Rol",
          "folder_user_concept_id" => "Tipo de responsable",
          "concept" => "Concepto"
      }
      attributes[key]
    end

    def generate
      @quotation = @folder.generate_quote
    end

    def get_buyer(buyer)
      buyers = {
          Folder::BUYER[:OWNER] => "Propietario",
          Folder::BUYER[:COOWNER] => "Copropietario"
      }
      buyers[buyer]
    end

    def get_status(status)
      statuses = {
          Folder::STATUS[:ACTIVE] => "Activo",
          Folder::STATUS[:EXPIRED] => "Expirado",
          Folder::STATUS[:CANCELED] => "Cancelado",
          Folder::STATUS[:ACCEPTED] => "Tesoreria",
          Folder::STATUS[:REJECTED] => "Rechazado",
          Folder::STATUS[:APPROVED] => "Finalizado",
      }
      statuses[status]
    end

    def slice_amr
      if @folder.canceled?
        @amr = @quotation.amr.each_slice(20).to_a
      else
        @amr = Installment.where(folder: @folder, deleted_at: nil, concept: Installment::CONCEPT[:FINANCING])
        @smaller_amortization = Setting.find_by_key("smaller_amortization_table").try(:convert)

        if @smaller_amortization
          @amr = @amr.sort_by { |payment| payment.number.to_i }.each_slice(40).to_a.each_slice(2).to_a
        else
          @amr = @amr.sort_by { |payment| payment.number.to_i }.each_slice(20).to_a
        end
      end
    end

    def verify_access
      if @folder.present?
        folders = get_folders(params: params, with_hidden: true)
        raise CanCan::AccessDenied unless folders.include?(@folder)
      end
    end

    def can_cancel_folder?
      (@folder_without_active_payments || can?(:cancel_approved_with_payments, Folder)) && @step_role&.can_cancel? && !@folder.canceled?
    end

    def set_last_rejected_evaluation_folders
      step_log_query = { status: Folder::STATUS[:ACTIVE], step: @folder.step } unless @folder.finished?

      last_rejected_evaluation_folder = @folder.evaluation_folders.rejected.newest

      if last_rejected_evaluation_folder.present? && (@folder.fresh? || @folder.under_revision?) && @folder.step_logs.where(step_log_query).size > 1
        start_date = last_rejected_evaluation_folder.created_at
        @rejected_ev_folder = @folder.evaluation_folders.rejected.where(created_at: (start_date - 15.seconds)..(start_date + 15.seconds))
      end
    end

    def filter_params
      params.permit(:email, :name, :lot, :status, :project, :phase, :stage, :salesman, :branch)
    end

    def set_installments
      @installments = Installment.where(folder: @folder, deleted_at: nil)
      @down_payment_installments = @installments.where.not(concept: [Installment::CONCEPT[:FINANCING], Installment::CONCEPT[:LAST_PAYMENT]])
      @down_payment_installments = @down_payment_installments.sort_by { |payment| payment.number.to_i }
      @amr_installments = @installments.where(concept: Installment::CONCEPT[:FINANCING])
      @last_payment_installments = @installments.where(concept: Installment::CONCEPT[:LAST_PAYMENT])
      @amr_installments = @amr_installments.sort_by { |payment| payment.number.to_i }
      @amr_installments += @last_payment_installments
    end

    def canceled_totals
      @capital_total = @quotation.amr.inject(0) { |sum, payment| sum + payment[:capital] }
      @interest_total = @quotation.amr.inject(0) { |sum, payment| sum + payment[:interest] }
      @down_payment_total = @quotation.down_payment_monthly_payments.inject(0) { |sum, payment| sum + payment[:payment] }
      @payment_total = @quotation.amr.inject(0) { |sum, payment| sum + payment[:payment] }
      @payment_total += @down_payment_total
      @down_payment_total += @quotation.amr.inject(0) { |sum, payment| sum + payment[:down_payment] } if @quotation.is_down_payment_differ
      @capital_payments_total = @quotation.amr.inject(0) { |sum, payment| sum + payment[:capital_payment] } if @quotation.have_capital_payment
    end

    def active_totals
      @capital_total = @amr_installments.pluck(:capital).sum(&:to_f)
      @interest_total = @amr_installments.pluck(:interest).sum(&:to_f)
      @down_payment_total = @down_payment_installments.pluck(:total).sum(&:to_f)
      @payment_total = @amr_installments.pluck(:total).sum(&:to_f)
      @payment_total += @down_payment_installments.pluck(:total).sum(&:to_f)
      @down_payment_total += @amr_installments.pluck(:down_payment).sum(&:to_f) if @quotation.is_down_payment_differ
      @capital_payments_total = @amr_installments.inject(0) { |sum, payment| sum + payment.capital_payment } if @quotation.have_capital_payment
    end

    def payment_modal_permissions
      @gateway_types = []

      @can_send_by_whatsapp = @step_role&.send_by_whatsapp? || false
      @can_send_by_email = @step_role&.send_by_email? || false
      @can_copy_to_clipboard = @step_role&.copy_to_clipboard? || false
      @can_suscribe = can?(:create, Subscription) && @folder&.stage&.enterprise&.online_payment_services&.netpay&.available&.any? || false
      @cannot_perform_subscription = @folder&.total_amount_overdue > 0
      @can_create_subscription = can?(:create, Subscription) && !@folder&.active_subscription? || false
      @can_cancel_subscription = can?(:destroy, Subscription) && @folder&.active_subscription? || false
      @can_update_suscription = can?(:update, Subscription) && @folder&.active_subscription? || false
      @active_suscription = @folder&.subscription&.id
      @suscription_items = @folder&.subscriptions&.currently_active || []
      @clients = @folder.clients
      @gateway_types << { id: "down-payment", text: "Pagos iniciales y servicios adicionales" }
      @gateway_types << { id: "finance", text: "Financiamiento de capital y enganche" } if can_pay_on_this_step(@folder, @step_role&.can_make_installments?)
      @gateway_types << { id: "suscription", text: "Domiciliación" } if @can_create_subscription && can_pay_on_this_step(@folder, @step_role&.can_make_installments?)
    end

    def set_folder_user_concepts
      @folder_user_concepts = FolderUserConcept.all
    end

    def set_automatic_cash_back(current_user, folder)
      credit_scheme = folder.stage.credit_scheme
      payment_method = credit_scheme.payment_method
      cash_back_amount = credit_scheme.reffered_client_amount
      payment_way = credit_scheme.reffered_client_payment_way
      cash_back_amount = payment_way == "percentage" ? (folder.total_sale * (cash_back_amount / 100)).round(2) : cash_back_amount

      return unless payment_method.present? && payment_method.cash_back && payment_method.reffered_client_cash_back

      client = @folder.client
      referred_count = ReferredClient.where(client: client).size

      if payment_method.reffered_client_cash_back_multiple || (client.folders.size == 1 && !payment_method.reffered_client_cash_back_multiple)
        create_cash_back(client, current_user, cash_back_amount * referred_count, folder, payment_method)
      end
    end

    def create_cash_back(client, current_user, cash_back_amount, folder, payment_method)
      CashBack.create(client: client, user: current_user, amount: cash_back_amount, exclusive_folder_id: folder.id, payment_method: payment_method)
    end
end
