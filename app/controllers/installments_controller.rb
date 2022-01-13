# frozen_string_literal: true

class InstallmentsController < ApplicationController
  include QuotationsHelper, InstallmentsHelper, InstallmentConcern, PaymentProcessorConcern, PaymentsHelper, FoldersHelper, EntityNamesConcern, AdditionalConceptsHelper, DateHelper, CashFlowHelper, CustomInstallmentsHelper
  authorize_resource except: [:mail_account_status, :mail_payment_due_soon, :download_account_status, :send_account_status]
  before_action :set_folder
  before_action :set_project_entity_names_by_folder, only: [:show, :create, :account_status, :custom_installments]
  before_action :set_step_role, except: [:mail_account_status, :download_account_status, :send_account_status]
  before_action :generate
  before_action :set_configuration, :validate_errors, only: [:show, :account_status, :mail_account_status, :mail_payment_due_soon, :create, :download_account_status, :send_account_status, :new_restructure, :payment_settings, :payment_tabs_settings]
  before_action :set_default_quote, only: [:account_status, :mail_account_status, :download_account_status, :send_account_status]
  before_action :set_cash_back, only: [:create]
  before_action :set_down_payment_amount_to_subscribe, only: :show
  before_action :set_additional_concept, only: [:create]
  before_action :set_additional_concept_payments, only: [:show, :account_status, :mail_account_status, :download_account_status, :send_account_status, :new_additional_concept_payment]
  before_action :set_custom_balance, only: [:custom_installments, :process_custom_installments, :create_custom_installments]
  before_action :transform_new_capital_data, only: [:payment_tabs_settings, :new_restructure, :mail_payment_due_soon]
  before_action :transform_new_payment_data, only: [:show, :new_payment, :payment_settings, :account_status, :mail_account_status, :download_account_status, :send_account_status]
  before_action :slice_payments, only: [:account_status, :mail_account_status, :download_account_status, :send_account_status]
  before_action :get_permissions, only: [:show, :payment_settings]
  before_action :validate_custom_installments, only: [:custom_installments, :process_custom_installments, :create_custom_installments]

  def show
    raise CanCan::AccessDenied.new("No tiene permisos para acceder a cobranza en este expediente") if @folder.step.present? && !@folder.step.installments_step
    @first_permission = @custom_installment_permissions.first
  end

  def payment_settings
  end

  def payment_tabs_settings
    @disabled = false
    @show_amount = false
    @exclude_cash_back = false
    @cannot_add_capital_payments = false
    @restructure_message = ""
    @is_down_payment_differ = @quotation.is_down_payment_differ
    @can_show_form = true
    case params[:tab_type]
    when Installment::TAB_TYPES[:NEW_PAYMENT]
      @show_amount = true
      @can_show_form = current_user.role.permissions.where(action: Installment::TAB_TYPES[:NEW_PAYMENT]).any?
    when Installment::TAB_TYPES[:NEW_CAPITAL]
      @show_amount = true
      @disabled = false
      can_apply_capital_with_overdue = can?(:apply_capital_with_overdue, Installment) ? false : @has_financing_restriction_overdue
      @has_restructure = @actual.restructure_concepts(false).select { |c| c.concept != "day" }.any? if @actual.present?

      @cannot_add_capital_payments = @has_financing_restriction_overdue || @has_restructure || @next_installment[:number] == "A" if cannot?(:apply_capital_with_overdue, Installment)
      @restructure_message = tooltip_message(@has_restructure, false, false, @next_installment[:number] == "A", can_apply_capital_with_overdue)
    when Installment::TAB_TYPES[:NEW_RESTRUCTURE]
      @show_amount = false
      @disabled = false
      @cannot_add_capital_payments = @has_restructure || @next_installment[:is_down_payment]
      @restructure_message = tooltip_message(@has_restructure, false, @next_installment[:is_down_payment], false)
    when Installment::TAB_TYPES[:NEW_DATE]
      @cannot_add_capital_payments = @next_installment[:concept] != Installment::CONCEPT[:FINANCING]
      @restructure_message = tooltip_message(false, false, true)
    when Installment::TAB_TYPES[:NEW_DELAY]
      @cannot_add_capital_payments = @has_restructure || @next_installment[:is_down_payment]
      @restructure_message = tooltip_message(@has_restructure, false, @next_installment[:is_down_payment], false, @has_delay_restriction)
    when Installment::TAB_TYPES[:NEW_ADDITIONAL_CONCEPT_PAYMENT]
      @show_amount = true
      @payment_methods = @payment_methods.where(cash_back: false)
      @additional_concept_options = additional_concept_options(@folder, @stage).compact
    end
  end

  def new_payment
  end

  def new_restructure
    @day_message = ""
    @invalid_capital_payment = [Restructure::CONCEPT[:FINANCING_MONTHLY], Restructure::CONCEPT[:FINANCING_TIME]].include?(params[:restructure_type]) && params[:amount].to_i < @stage.credit_scheme.min_capital_payment
    @invalid_day_restructure = Restructure::CONCEPT[:DAY] == params[:restructure_type] && (@new_day > @custom_day.to_i || @grace_months > @stage.credit_scheme.max_grace_months)
    @invalid_restructure = Restructure::CONCEPT[:RESTRUCTURE] == params[:restructure_type] && @total_payments < @min_total_payments
    @invalid_delay = Restructure.delay_concept?(params[:restructure_type]) && params[:delay_months].to_i > @stage.credit_scheme.max_delay_payments

    if @invalid_day_restructure
      @day_message = "Superaste la cantidad máxima de meses de gracia" if @grace_months > @stage.credit_scheme.max_grace_months
      @day_message = "No es posible utilizar la fecha de pago seleccionada" if @new_day > @custom_day.to_i
    end
  end

  def new_additional_concept_payment
  end

  def create
    return if @locals[:warning].present?
    amount = params[:amount].to_f
    ActiveRecord::Base.transaction do
      @cash_flow = @folder.generate_cash_flow(params[:restructure_type],  @payment_method, @bank_account, @branch, amount, @date, @client)[:cash_flow]

      if @additional_concept.present?
        create_concept_payment(cash_flow: @cash_flow, additional_concept: @additional_concept)
      else

        if params[:restructure_type].blank?
          payment = @folder.pay_installments(amount, @branch, @cash_flow)
        else
          payment = @folder.create_restructure(params[:restructure_type], params[:is_down_payment], params[:concept], amount, params[:next], @branch, @cash_flow, @down_payment_count, @payments_count, @new_day, @current_discount, @grace_months, @delay_months)
        end
        @locals = payment[:locals]
        @payment = payment[:payment]

      end
    end

  rescue Exception => error
    Bugsnag.notify(error) unless @locals[:warning].present?
  end

  def mail_account_status
    account_status_mailer(@folder.client)
  end

  def mail_payment_due_soon
    payment_due_soon_mailer(@folder.client, @next_installment[:date])
  end

  def account_status
    @name = "Estado de Cuenta"
    @bank_accounts = @folder.stage.enterprise.bank_accounts

    respond_to do |f|
      f.pdf { render_pdf @name, "installments/new_format/account_status.html.erb" }
      f.html { render file: "installments/new_format/account_status.html.erb", layout: "pdf.html" } unless Rails.env.production?
    end
  end

  def download_account_status
    respond_to do |format|
      format.html { render layout: "availability" }
    end
  end

  def send_account_status
    @client = get_client
    account_status_mailer(@client)
  end

  def custom_installments
    respond_to do |format|
      format.html
    end
  end

  def process_custom_installments
    only_load = params[:only_load]
    @add_item = params[:add_item]
    @has_no_custom_payments = @folder.has_no_custom_payments?
    @has_custom_payments = @folder.has_custom_payments?
    total_installments = @folder.payment_scheme.credit_scheme.periods.sum(:payments)
    if only_load
      @custom_installments = @folder.installments.order("number::integer asc").custom
      @capital_residue = @custom_installments.last&.debt
      @is_payments_limit = total_installments == @custom_installments.size
    else
      @custom_installments = calculate_installments(custom_installments_params, @folder, @total_sale)
      @is_payments_limit = total_installments == @custom_installments.size

      @capital_residue = 0

      if @add_item && !@is_payments_limit
        last = @custom_installments.last
        last_total_sale = @custom_installments.size == 0 ? @total_sale : (last&.debt.presence || 0)
        @custom_installments << Installment.new(
          number: last.present? ? last.number.to_i + 1 : 1,
          concept: Installment::CONCEPT[:FINANCING],
          capital: 0,
          interest: 0,
          down_payment: 0,
          total: 0,
          debt: last_total_sale,
          folder_id: @folder.id,
          date: last.present? ? (last.date.present? ? last.date.next_month(1) : Time.zone.now) : Time.zone.now,
          is_custom: true
        )
      end

      if @custom_installments.last.present?
        @capital_residue = @custom_installments.last.debt
      end
    end
  end

  def create_custom_installments
    begin
      custom_installments = calculate_installments(custom_installments_params, @folder, @total_sale)
      ActiveRecord::Base.transaction do
        installments = @folder.installments.active.where(concept: Installment::CONCEPT[:FINANCING]).where.not(id: custom_installments.pluck(:id))
        installments.update_all(deleted_at: Time.zone.now) unless installments.empty?
        custom_installments.each do |installment|
          installment.save!
        end
      end
    rescue StandardError => ex
      Bugsnag.notify(ex)
      render json: {  message:  "Ocurrió un error al guardar las cuotas personalizadas."  }, status: 404
    end

    render json: { message: "Cuotas personalizadas guardadas con éxito." }, status: :created
  end

  private

    def set_folder
      @folder = Folder.includes(:payment_scheme, :client, lot: { stage: { phase: :project } }).find(params[:folder_id])
      @clients = @folder.clients
      @project = @folder.project
      @phase = @folder.phase
      @stage = @folder.stage
      @lot = @folder.lot
      @payment_method = PaymentMethod.find(params[:payment_method]) if params[:payment_method].present?
      @branch = Branch.find(params[:branch]) if params[:branch].present?
      # TODO: scope only for the accounts in the project
      @bank_account = BankAccount.find(params[:bank_account]) if params[:bank_account].present?
      @date = can?(:set_date, Installment) && params[:date].present? ? params[:date].to_date : Time.zone.now
      @client = params[:client].present? ? Client.find(params[:client]) : @folder.client
    end

    def set_step_role
      @step_role = @folder&.step&.step_roles&.find_by(role: current_user.role)
    end

    def set_default_quote
      @is_default_quote = true
      generate
      @payment_total_default = @default_quotation.total_with_discount
    end

    def get_permissions
      has_custom_installments = @folder.has_custom_installments?
      role_permissions = current_user.role.permissions
      permissions = []
      permissions << { key: Installment::TAB_TYPES[:NEW_PAYMENT], label: "Nuevo Pago" }
      permissions << { key: Installment::TAB_TYPES[:NEW_CAPITAL], label: "Abonos a capital" } if role_permissions.where(action: Installment::TAB_TYPES[:NEW_CAPITAL]).any? && !has_custom_installments && @next_installment.present?
      permissions << { key: Installment::TAB_TYPES[:NEW_RESTRUCTURE], label: "Restructura de saldo" } if role_permissions.where(action: Installment::TAB_TYPES[:NEW_RESTRUCTURE]).any? && !has_custom_installments && @next_installment.present?
      permissions << { key: Installment::TAB_TYPES[:NEW_DATE], label: "Cambio de fecha" } if role_permissions.where(action: Installment::TAB_TYPES[:NEW_DATE]).any? && !has_custom_installments && @next_installment.present?
      permissions << { key: Installment::TAB_TYPES[:NEW_DELAY], label: "Prórroga" } if role_permissions.where(action: Installment::TAB_TYPES[:NEW_DELAY]).any? && !has_custom_installments && @next_installment.present?
      permissions << { key: Installment::TAB_TYPES[:NEW_ADDITIONAL_CONCEPT_PAYMENT], label: "Servicios adicionales" } if can?(:new_additional_concept_payment, Installment)
      @custom_installment_permissions = permissions
    end

    def set_cash_back
      @locals = {}
      @installments_helper_for_jbuilder = installments_helper_for_jbuilder
      if params[:bonus_residue].present? && @payment_method.present? && @payment_method.cash_back.present?
        @cash_back_available = @client.cash_back_available(@folder.id, payment_method: @payment_method)
        if params[:amount].to_f > @cash_back_available
          @locals = { warning: "not_enough", cash_back_available:  @cash_back_available }
        end

        if params[:bonus_residue].present? && params[:amount].to_f > params[:bonus_residue].to_f
          @locals = { warning: "not_allowed" }
        end
      end
    end

    def set_down_payment_amount_to_subscribe
      @overdue = false
      @all_installments.each_with_index do |installment, index|
        next if installment[:number] == "A"
        if index + 1 <= @quotation.down_payment_monthly_payments.length
          concept = Installment::CONCEPT[:DOWN_PAYMENT]
        else
          concept = Installment::CONCEPT[:FINANCING]
        end
        actual = @folder.installments.find { |element| element.number.to_i == installment[:number] && element.down_payment > 0 && element.concept == concept }

        if actual.present?
          total_paid = actual.total_paid
          if total_paid > 0
            next
          end
        end

        @overdue = true if installment[:date].strftime("%Y/%m/%d") < Time.zone.now.strftime("%Y/%m/%d")
        if @next.nil?
          @next = installment

          number = installment[:number]
          number += (@folder.payment_scheme.start_installments || 0) if concept == Installment::CONCEPT[:FINANCING]
          @next[:months_to_subscribe] = get_down_payment_months_to_subscribe(number)
          break
        end
      end
    end

    def get_down_payment_months_to_subscribe(number)
      @quotation.down_payment_finance - number + 1
    end

    def get_client
      client = @folder.client
      if @folder.clients.length > 1 && params[:coowner].present?
        client = @folder.clients.find { |coowner| coowner.id == params[:coowner].to_i }
      end
      client
    end

    def has_coowner?
      @folder.clients.length > 1
    end

    def account_status_mailer(client)
      @name = "Estado de Cuenta"
      @bank_accounts = @folder.stage.enterprise.bank_accounts
      pdf = render_to_string("installments/new_format/account_status.html.erb", layout: "pdf")
      @project = @folder.lot.project
      PaymentMailer.send_account_status(@folder.client.email, pdf, @folder.client, @folder, @project.project_entity_name, @project.phase_entity_name, @project.stage_entity_name).deliver_later

      respond_to do |format|
        format.js { render "installments/mail_account_status.js.erb" }
      end
    end

    def payment_due_soon_mailer(client, date)
      PaymentMailer.payment_due_soon(client.email, client, @folder, date).deliver_later

      respond_to do |format|
        format.js { render "installments/mail_payment_due_soon.js.erb" }
      end
    end

    def validate_restructure(folder, next_payment_installment, concept, restructure_type)
      multiple_hash = {
        installment: next_payment_installment,
        multiple_restructure: false,
        concept: concept,
        is_restructure: false
      }

      next_installment_only_payments = []
      is_last_down_payment = false
      has_restructure = false
      multiple_restructure = false
      is_restructure = (restructure_type == Restructure::CONCEPT[:RESTRUCTURE])
      paid_payments = folder.paid_installments
      last_down_payment = folder.down_payments_installments.first
      next_installment = Installment.find_by(number: next_payment_installment, folder: folder, concept: concept)
      is_down_payment_restructure = [Restructure::CONCEPT[:DOWN_PAYMENT_MONTHLY], Restructure::CONCEPT[:DOWN_PAYMENT_TIME]].include?(restructure_type)

      return multiple_hash unless paid_payments.length > 0

      last_payment = paid_payments.first
      before_last_payment = paid_payments.second
      restructure = before_last_payment.payments.map { |payment|payment.restructure unless payment.restructure.nil? }.compact if before_last_payment.present?
      has_restructure = next_installment.payments.map { |payment|payment.restructure if payment.restructure.present? ? payment.restructure.concept == Restructure::CONCEPT[:RESTRUCTURE] : false }.any? if next_installment.present?
      next_installment_only_payments = next_installment.payments.map { |payment| payment unless payment.restructure.present? }.compact if next_installment.present?
      is_last_down_payment = (last_payment == last_down_payment) if last_down_payment.present?
      last_payment_date_pass = (concept == Installment.concepts[:financing] ? last_payment.is_paid? : true)
      multiple_restructure = !is_down_payment_restructure && last_payment_date_pass && next_installment.date.strftime("%m/%Y") > Time.now.end_of_day.strftime("%m/%Y") && !restructure.present? && next_installment_only_payments.empty? && !is_last_down_payment && last_payment.capital != 0 if next_installment.present?

      multiple_hash[:multiple_restructure] = multiple_restructure

      return multiple_hash unless multiple_restructure

      multiple_hash[:installment] = last_payment.number.to_i
      return multiple_hash if restructure_type == Restructure::CONCEPT[:FINANCING_MONTHLY] || restructure_type == Restructure::CONCEPT[:DAY]
      multiple_hash[:installment] = next_payment_installment if restructure_type == Restructure::CONCEPT[:DELAY_IMMEDIATE] || restructure_type == Restructure::CONCEPT[:DELAY_ALTERNATE] || restructure_type == Restructure::CONCEPT[:DELAY_LAST] || is_restructure || has_restructure
      multiple_hash[:is_restructure] = is_restructure || has_restructure
      multiple_hash
    end

    def restructure_installment(adjust, folder, lot, restructure_type, down_payment_count, next_down_payment, next_installment_financing, next_date, new_date, delay_months, amount, without_promotions)
      installment_concept = Installment::CONCEPT[:FINANCING]

      if adjust > folder.payment_scheme.total_payments
        relative_plan = get_relative_plan(adjust, lot)
        @current_discount = relative_plan[:discount]
        @total_payments = adjust
      end

      if [Restructure::CONCEPT[:DOWN_PAYMENT_MONTHLY], Restructure::CONCEPT[:DOWN_PAYMENT_TIME]].include?(restructure_type)
        next_term = down_payment_count
        next_installment = next_down_payment
        installment_concept = Installment::CONCEPT[:DOWN_PAYMENT]
      else
        next_term = adjust
        next_installment = next_installment_financing
      end

      if Restructure::CONCEPT[:DAY] == restructure_type
        next_date = next_date.to_date

        new_date = new_date.to_date
        @new_day = new_date.strftime("%d").to_i
        @custom_day = @new_day > 31 ? 31 : @new_day
        @grace_months = (new_date.year * 12 + new_date.month) - (next_date.year * 12 + next_date.month)
      end

      @delay_months = delay_months.present? ? delay_months.to_i : 0

      @multiple_restructure = validate_restructure(folder, next_installment, installment_concept, restructure_type)

      {
        folder_id: folder.id,
        installment_number: @multiple_restructure[:installment],
        capital_paid: amount.to_f,
        concept: restructure_type,
        current_term: next_term || @total_payments,
        current_discount: @current_discount,
        current_day: @custom_day,
        grace_months: @grace_months,
        delay_months: @delay_months,
        without_promotions: without_promotions
      }
    end

    def set_additional_concept
      @additional_concept = AdditionalConcept.find_by(id: params[:additional_concept])
    end

    def custom_installments_params
      installments = []
      return installments unless params[:installments].present?
      number = 0
      params[:installments].each do |custom_installment|
        number = number + 1
        installment = Installment.find_or_initialize_by(id: custom_installment[:id])
        installment.number = number
        installment.concept = Installment::CONCEPT[:FINANCING]
        installment.folder_id = @folder.id
        installment.date = custom_installment[:date]
        installment.capital = custom_installment[:capital]
        installment.interest = 0
        installment.down_payment = 0
        installment.total = 0
        installment.debt = 0
        installment.is_custom = true
        installments << installment
      end
      installments
    end

    def set_custom_balance
      @total_sale = @folder.total_sale.to_d - @folder.total_down_payment.to_d
    end

    def transform_new_capital_data
      now = Time.zone.now
      down_payment_grace_months = @folder.payment_scheme.start_installments || 0
      @all_installments.each_with_index do |installment, index|
        pending_payment = 0
        is_down_payment = index + 1 <= @quotation.down_payment_monthly_payments.length
        is_last_payment = @all_installments[index][:concept] == Installment::CONCEPT[:LAST_PAYMENT]
        concept = index == 0 ? Installment::CONCEPT[:INITIAL_PAYMENT] : is_down_payment ? Installment::CONCEPT[:DOWN_PAYMENT] : Installment::CONCEPT[:FINANCING]
        concept = Installment::CONCEPT[:LAST_PAYMENT] if is_last_payment
        pending_capital = installment[:down_payment] + (installment[:capital] || 0)
        actual = @installments.select { |element| (element.number == installment[:number].to_s && element.concept == concept) }.first

        init_installment(@all_installments[index], installment, is_down_payment, @all_installments, concept, @folder)

        if actual.present?
          total_amount = actual.total
          installment[:date] = actual.date
          total_paid = actual.total_paid

          if actual.penalty.present? && actual.penalty.active
            total_amount += actual.penalty.amount
            set_penalty(@all_installments[index], actual.penalty.amount)
          else
            @all_installments[index][:can_show_new_folder_installment] = can?(:create, Penalty)
          end

          if total_paid >= total_amount
            @all_installments[index][:paid] = true
          else
            pending_payment = total_amount - total_paid
            set_installment_residue(@all_installments[index], total_amount, total_paid)

            if @next_installment.nil?
              @next_installment = set_next_installment(installment, concept)
              @next_down_payment = set_nex_down_payment(installment, is_down_payment, down_payment_grace_months)
              @current_installment = @all_installments[index - 1] if (index - 1) >= 0
              validate = validate_restructure(@folder, @next_installment[:number], @next_installment[:concept], params[:restructure_type])

              if @current_installment.present? && validate[:multiple_restructure]
                @current_installment[:row_color] = installment_table_class(paid: @current_installment[:paid],
                                                                            overdue: @current_installment[:overdue],
                                                                            next_overdue: @current_installment[:next_overdue],
                                                                            is_multiple: true)

              end

              if !(validate[:multiple_restructure] && validate[:is_restructure])
                @actual = actual

                @has_restructure = actual.restructure_concepts(false).any?
              end

            end
          end

        else
          @all_installments[index][:residue] = installment[:payment].round(2)
          if @next_installment.nil? && installment[:payment] != 0
            @next_installment = set_next_installment(installment, concept)
            @next_down_payment = set_nex_down_payment(installment, is_down_payment, down_payment_grace_months)
          end
        end

        @total_residue += pending_payment

        if installment[:date] < now && pending_payment > 0

          @all_installments[index][:overdue] = true
          @capital_amount_overdue += pending_capital
          @amount_overdue += pending_payment
        end

        if installment[:date] >= now && installment[:date] < now.next_day(@stage.payment_expiration) && pending_payment > 0
          @all_installments[index][:next_overdue] = true
        end
        installment_complements(@all_installments[index], installment, @next_installment)
      end

      @capital_payment_concepts = []
      @has_financing_restriction_overdue = true if @capital_amount_overdue > 0
      @capital_payment_concepts = get_capital_payment_concepts if @next_installment.present? && @next_installment[:concept] != Installment::CONCEPT[:INITIAL_PAYMENT]
    end

    def init_installment(virutal_installment, installment, is_down_payment, installments, concept, folder)
      virutal_installment[:is_down_payment] = is_down_payment
      virutal_installment[:interest] = installment[:interest].nil? ? 0 : installment[:interest]
      virutal_installment[:capital] = installment[:capital].nil? ? 0 : installment[:capital]
      virutal_installment[:position] = installments.index(installment)
      virutal_installment[:concept] = concept
      virutal_installment[:row_color] = ""
      virutal_installment[:status_message] = ""
      virutal_installment[:residue] = 0
      virutal_installment[:penaly] = 0
      virutal_installment[:paid] = false
      virutal_installment[:has_penalty] = false
      virutal_installment[:can_show_new_folder_installment] = false
      virutal_installment[:can_show_folder_installment_penalties] = false
      virutal_installment[:can_add_penalty] = false
      virutal_installment[:add_penalty_url] = new_folder_installments_penalties_path(folder, installment)
      virutal_installment[:remove_penalty_url] = folder_installments_penalties_path(folder, installment)
    end

    def get_capital_payment_concepts
      capital_payment_concepts = []
      capital_payment_concepts << { restructure_concept: Restructure::CONCEPT[:FINANCING_MONTHLY], label: "Abono a capital (monto)" } if @next_installment[:concept] == Installment::CONCEPT[:FINANCING]
      capital_payment_concepts << { restructure_concept: Restructure::CONCEPT[:FINANCING_TIME], label: "Abono a capital (plazo)" } if @next_installment[:concept] == Installment::CONCEPT[:FINANCING]
      capital_payment_concepts << { restructure_concept: Restructure::CONCEPT[:DOWN_PAYMENT_MONTHLY], label: "Abono a enganche (monto)" } if !@next_installment[:down_payment].zero? && can?(:apply_capital_down_payment, Installment)
      capital_payment_concepts << { restructure_concept: Restructure::CONCEPT[:DOWN_PAYMENT_TIME], label: "Abono a enganche (plazo)" } if !@next_installment[:down_payment].zero? && can?(:apply_capital_down_payment, Installment)
      capital_payment_concepts
    end

    def set_penalty(installment, penalty_amount)
      installment[:penalty] = penalty_amount
      installment[:has_penalty] = true
      installment[:can_show_folder_installment_penalties] = can?(:create, Penalty)
    end

    def set_installment_residue(installment, total_amount, total_paid)
      installment[:residue] = total_amount - total_paid
    end

    def set_next_installment(installment, concept)
      next_installment = installment
      next_installment[:concept] = concept
      next_installment
    end

    def set_nex_down_payment(installment, is_down_payment, down_payment_grace_months)
      next_down_payment = installment[:number] if is_down_payment
      next_down_payment = installment[:number] + down_payment_grace_months if !is_down_payment && installment[:down_payment].to_f > 0
      next_down_payment
    end

    def installment_complements(virtual_installment, installment, next_installment)
      now = Time.zone.now
      overdue = virtual_installment[:date].to_date < now && virtual_installment[:residue] > 0
      virtual_installment[:row_color] = installment_table_class(paid: virtual_installment[:paid], overdue: virtual_installment[:overdue], next_overdue: virtual_installment[:next_overdue], is_multiple: virtual_installment[:is_multiple])
      virtual_installment[:status_message] = installment_table_message(paid: virtual_installment[:paid], overdue:  virtual_installment[:overdue], next_overdue: virtual_installment[:next_overdue], is_multiple: virtual_installment[:is_multiple])
      virtual_installment[:can_add_penalty] = virtual_installment[:residue] <= 0 || installment == next_installment
      virtual_installment[:date] = installment[:date].strftime("%d/%m/%Y")
      virtual_installment[:overdue_days] = installment_overdue_days(overdue, now.to_date, virtual_installment[:date].to_date)
    end

    def set_bonus_residue(next_installment, installment, total_paid, pending_payment)
      amount_available = 0

      only_capital_payment = installment.capital || 0
      only_interest_payment = installment.interest || 0
      only_down_payment = installment.down_payment || 0

      if @payment_method.present?
        amount_available += only_capital_payment if @payment_method.capital
        amount_available += only_interest_payment if @payment_method.interest
        amount_available += only_down_payment if @payment_method.down_payment
      end

      bonus_paid = installment.bonus_paid
      bonus_validation = total_paid
      bonus_validation -= bonus_paid
      bonus_validation -= only_capital_payment  unless @payment_method.capital
      bonus_validation -= only_interest_payment unless @payment_method.interest
      bonus_validation -= only_down_payment unless @payment_method.down_payment
      bonus_residue = bonus_validation >= 0 ? pending_payment : amount_available - bonus_paid
      next_installment[:bonus_residue] = bonus_residue.round(2)
    end

    def installments_helper_for_jbuilder
      installments_helper ||= Class.new do
        include InstallmentsHelper
      end.new
      installments_helper
    end

    def validate_custom_installments
      if cannot?(:custom_installments, Folder) && !@step_role.can_manage_custom_installments?
        raise CanCan::AccessDenied.new("No tiene permisos para crear cuotas personalizadas")
      end
    end
end
