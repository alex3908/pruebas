# frozen_string_literal: true

class Api::V1::QuotesController < API::V1::BaseController
  include QuotationHandler, QuotationsHelper, DiscountsHelper, EntityNamesConcern
  before_action :set_lot_and_relatives
  before_action :set_project_entity_names_by_project
  before_action :load_clients, only: [:index]
  before_action :validate_reserve_with_file_json, only: [:reserve]
  before_action { set_quotation(current_user) }
  before_action :validate_access_json
  before_action :set_custom_data
  before_action :generate
  helper_method :encode_base_64

  def index
    @can_reserve = can?(:reserve, :quote)
    @invalid_rules = validate_rules
  end

  def reserve
    today = Time.zone.now.to_datetime
    locked_period_days_behind = @lot.stage.lock_seller_period.nil? ? today : today - @lot.stage.lock_seller_period
    expired_folders = Folder.where(status: Folder::STATUS[:EXPIRED], lot_id: @lot.id, user: current_user).where("expiration_date > :locked_period_days_behind", locked_period_days_behind: locked_period_days_behind).count

    if expired_folders > 0
      raise StandardError.new "No puedes reservar este #{@lot.project.lot_entity_name}, porque ha expirado recientemente."
    else

      if params[:folder].nil?
        @folder = Folder.new
      end

      validate_down_payment promotion: @promotion, promotion_valid: @promotion_valid, lot_price: @lot_price

      @folder.lot ||= @lot
      @folder.client ||= @client
      @folder.user ||= current_user
      @folder.buyer ||= Folder::BUYER[:OWNER]

      if @folder.new_record?
        @folder.payment_scheme = PaymentScheme.new

        if @stage.credit_scheme.requires_file
          @folder.documents = [
            Document.new(
              document_template: @stage.credit_scheme.document_template,
              file_versions: [ FileVersion.new(file: params[:file]) ]
            )
          ]
        end

      end

      @discount = Discount.where("total_payments <= (?) AND is_active = (?) AND stage_id = (?)", params[:total_payments].to_i, true, @lot.stage).order(total_payments: :desc).first
      @relative_plan = get_relative_plan(params[:total_payments].to_i, @lot)
      discount = @relative_plan[:discount]
      total_payments = params[:total_payments]
      plan_name = total_payments == 1 ? "Contado" : "#{total_payments} meses"
      first_payment = params[:first_payment].to_i
      start_installments = @stage.credit_scheme.start_installments

      if @promotion_valid
        start_installments = @promotion.start_installments
      end

      @folder.payment_scheme.assign_attributes(
        name: plan_name,
        buy_price: @lot.price_with_additional,
        down_payment: @down_payment_amount,
        down_payment_finance: @down_payment_finance,
        total_payments: total_payments,
        discount: discount,
        initial_payment: @initial_payment,
        first_payment: first_payment,
        promotion: @promotion.amount,
        promotion_name: @promotion.name,
        promotion_operation: @promotion.operation,
        start_installments: start_installments,
        credit_scheme: @stage.credit_scheme,
        immediate_extra_months: is_immediate_construction? ? @stage.credit_scheme.immediate_extra_months : 0,
        opening_commission: @stage.credit_scheme.is_opening_commission ? @stage.credit_scheme.opening_commission : 0
      )

      @folder.start_date = @custom_start_date.present? ? @custom_start_date : Time.zone.now
      @folder.payment_scheme.lock_payment = @quotation.complement_payment > 0 ? (@custom_quote.initial_payment - @quotation.complement_payment) : @custom_quote.initial_payment

      @folder.lot.with_lock do
        @unique_folder = Folder.find_by(lot_id: @lot.id, status: %w[active revision accepted rejected approved]).nil?
        raise StandardError.new "Este #{@folder.lot.project.lot_entity_name} cuenta con una reserva activa." unless @unique_folder || @folder.persisted?
        @folder.save!
        @folder.lot.status = Lot::STATUS[:RESERVED]
        @folder.lot.save!
        @quote_log.update!(folder_id: @folder.id) if can?(:reserve, :quote)
      end
    end
  rescue => exception
    render json: { message: exception.message }, status: :unprocessable_entity
  end

  private

    def validate_reserve_with_file_json
      if @stage.credit_scheme.requires_file && params[:file].nil?
        render json: { message: "Para poder reservar es necesario adjuntar el #{@stage.credit_scheme.document_template.name}." }, status: :unprocessable_entity
      end
    end

    def validate_access_json
      render json: { message: "No tiene permisos para generar una cotización" }, status: :unprocessable_entity if cannot?(:quote, :quote)
      render json: { message: "No tiene permisos para generar una cotización" }, status: :unprocessable_entity if !@stage.active && can?(:reserve, :quote)

      if params[:folder].present?
        folder = Folder.find_by!(id: params[:folder])
        can_edit_quote = (!folder.reserve_receipt.attached? && !folder.bank_deposit.attached? && !folder.down_payment_receipt.attached? && !folder.down_payment_voucher.attached?) || can?(:edit_with_files, :quote)
        can_custom_quote = (can?(:update_active, Folder) && (folder.active? || folder.rejected?)) ||
        (can?(:update_revision, Folder) && folder.revision?) || (can?(:update_accepted, Folder) && folder.accepted?) || (can?(:update_approved, Folder) && folder.approved?)

        unless folder.present? && folder.installments.includes(:payments).where(payments: { status: :active }).count <= 0 && @lot.id == folder.lot_id && can_edit_quote && (can_custom_quote || folder.user == current_user && %w[active rejected].include?(folder.status))
          render json: { message: "No tiene permisos para editar la cotización" }, status: :unprocessable_entity
        end
      end

      @unique_folder = Folder.find_by(lot_id: @lot.id, status: %w[active revision accepted rejected approved]).nil?
    end
    def validate_rules
      invalid_rules = []

      invalid_rules << "Puede ser del #{"%.2f" % (@min_downpayment_percentage * 100)}% hasta el #{"%.2f" % (@max_downpayment_percentage * 100)}% del precio del #{@project.lot_entity_name}." unless params[:down_payment_amount].to_f.between?(@min_downpayment_price.to_f, @max_downpayment_price.to_f)

      invalid_rules << @promotion_error if !@promotion_valid.nil? && !@promotion_valid

      invalid_rules << @promotion_coupon_error if !@promotion_coupon_valid.nil? && !@promotion_coupon_valid

      invalid_rules << "El plazo máximo de financiamiento son #{@total_periods} meses." if params[:total_payments].to_f > @total_periods
    end
end
