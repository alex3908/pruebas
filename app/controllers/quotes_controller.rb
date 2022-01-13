# frozen_string_literal: true

class QuotesController < ApplicationController
  include QuotationHandler, QuotationsHelper, DiscountsHelper, DownPaymentsHelper, DocumentsHelper, FoldersHelper, EntityNamesConcern

  authorize_resource class: false, only: [:quote]
  before_action :set_lot_and_relatives
  before_action :load_settings
  before_action :set_project_entity_names_by_project
  before_action :file_to_load
  before_action :load_clients, only: [:quote]
  before_action { set_quotation(current_user) }
  before_action :validate_access
  before_action :validate_reserve_with_file, only: [:reserve]
  before_action :set_custom_data
  before_action :generate
  helper_method :encode_base_64

  def quote
    if params[:email].present?
      @amr = @quotation.amr.each_slice(20).to_a
      html = render_to_string(@pdf, layout: "pdf")
      QuotationMailer.send_quotation(html, @client, @lot, current_user, @company_name).deliver_later
      @quote_log.update(email_delivered: true) if can?(:reserve, :quote)
    end

    respond_to do |format|
      format.pdf do
        if can?(:reserve, :quote) && @client.nil?
          redirect_to quote_project_phase_stage_lot_path(@project, @phase, @stage, @lot)
        else
          @quote_log.update(downloaded: true) if can?(:reserve, :quote)
          @amr = @quotation.amr.each_slice(20).to_a
          render pdf: "#{@lot_singular} No. #{@lot.name} Plan #{@quotation.plan_name}",
                 template: @pdf,
                 title: "#{@stage.name} - #{@lot_singular} #{@lot.name} - Plan #{@quotation.plan_name}",
                 layout: "pdf.html",
                 lowquality: true,
                 zoom: 1,
                 dpi: 75,
                 page_size: "Letter",
                 margin: {
                     top: 0,
                     bottom: 0,
                     left: 0,
                     right: 0
                 }
        end
      end
      format.html { render @file }
      format.js { render @file }
      format.json { render json: @quotation, status: :ok }
    end
  end

  def reserve
    today = Time.zone.now.to_datetime
    locked_period_days_behind = @lot.stage.lock_seller_period.nil? ? today : today - @lot.stage.lock_seller_period
    expired_folders = Folder.where(status: Folder::STATUS[:EXPIRED], lot_id: @lot.id, user: current_user).where("expiration_date > :locked_period_days_behind", locked_period_days_behind: locked_period_days_behind).count

    if expired_folders > 0
      respond_to do |format|
        format.html { render @file }
        format.js { render @reserve, locals: { error: "period-lock" } }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    else
      if params[:folder].nil?
        @folder = Folder.new
      end

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
      second_payment = params[:second_payment].to_i
      start_installments = @stage.credit_scheme.start_installments

      if @promotion_valid && @promotion.present?
        start_installments = @promotion.start_installments
      elsif @promotion_coupon_valid && @coupon.present?
        start_installments = @coupon.promotion.start_installments
      end

      @custom_quote = custom_quote(
        buy_price: @lot.price_with_additional,
        discount: discount,
        first_payment: first_payment,
        start_installments: start_installments,
        down_payment: @down_payment_amount,
        initial_payment: @initial_payment,
        down_payment_finance: @down_payment_finance,
        credit_scheme: @stage.credit_scheme,
          )

      previous_coupon = @folder.payment_scheme&.coupon

      @folder.payment_scheme.assign_attributes(
        name: plan_name,
        buy_price: @custom_quote.buy_price,
        down_payment: @custom_quote.down_payment - @custom_quote.initial_payment,
        down_payment_finance: @custom_quote.down_payment_finance,
        total_payments: total_payments,
        discount: @custom_quote.discount,
        initial_payment: @custom_quote.initial_payment,
        first_payment: @custom_quote.first_payment,
        promotion_discount: @custom_quote.promotion,
        promotion_name: @custom_quote.promotion_name,
        promotion_operation: @custom_quote.promotion_operation,
        promotion: @promotion.present? && @promotion.persisted? && !params[:promotion].blank? ? @promotion : nil,
        coupon: @coupon.present? && @coupon.persisted? && !params[:promotion_code].blank? ? @coupon : nil,
        start_installments: @custom_quote.start_installments,
        credit_scheme: @custom_quote.credit_scheme,
        immediate_extra_months: is_immediate_construction? ? @stage.credit_scheme.immediate_extra_months : 0,
        opening_commission: @custom_quote.credit_scheme.is_opening_commission ? @custom_quote.credit_scheme.opening_commission : 0,
        is_commissionable: @custom_quote.is_commissionable,
        max_commission_amount: set_max_commission_amount(total_payments.to_f, @stage.max_commission_amount),
        compound_interest: @custom_quote.credit_scheme.compound_interest,
        independent_initial_payment: @custom_quote.credit_scheme.independent_initial_payment,
        delivery_date: @stage.delivery_date,
        second_payment: second_payment,
        initial_payment_active: @custom_quote.credit_scheme.initial_payment_active,
        with_last_payment: @custom_quote.credit_scheme.has_last_payment,
        last_payment_amount: @last_payment_amount,
        is_relative_financing: @custom_quote.credit_scheme.is_relative_financing,
        area: @lot.area
      )

      @folder.start_date = @custom_start_date.present? ? @custom_start_date : Time.zone.now
      @folder.payment_scheme.zero_rate = (@custom_zero_rate.present? && can?(:custom_zero_rate, :quote)) ? @custom_zero_rate : nil
      @folder.payment_scheme.lock_payment = @quotation.complement_payment > 0 ? (@custom_quote.initial_payment - @quotation.complement_payment) : @custom_quote.initial_payment
      @folder.total_sale = @quotation.total_with_discount

      if can?(:custom_area, :quote) && params[:custom_area].present?
        @folder.payment_scheme.area = params[:custom_area].presence&.to_f
      end

      respond_to do |format|
        @folder.lot.with_lock do
          @unique_folder = Folder.find_by(lot_id: @lot.id, status: Folder::STATUS[:ACTIVE]).nil?
          if @unique_folder || @folder.persisted?
            if @folder.save
              # we need to update the installments because the folder
              # nested update does not execute payment scheme hooks
              @folder.payment_scheme.update_installments
              LotStatusJob.perform_later(@folder.id)

              @folder.payment_scheme.coupon.update(usages: @folder.payment_scheme.coupon.usages + 1) if @folder.payment_scheme.coupon.present? && (previous_coupon != @coupon)

              @quote_log.update(folder_id: @folder.id) if can?(:reserve, :quote)

              format.html { redirect_to @folder, success: "Reserva completada con exito." }
              format.js { render @reserve }
              format.json { render :show, status: :created, location: @folder }
            else
              format.html { render @file }
              format.js { render @reserve, locals: { error: @folder.errors.messages.values.join } }
              format.json { render json: @folder.errors, status: :unprocessable_entity }
            end
          else
            format.html { render @file }
            format.js { render @reserve, locals: { error: "lock" } }
            format.json { render json: @folder.errors, status: :unprocessable_entity }
          end
        end
      end
    end
  end

  private

    def load_settings
      @use_quote_select = Setting.find_or_create_by(key: "use_quote_select", data_type: "boolean").try(:convert)
    end
end
