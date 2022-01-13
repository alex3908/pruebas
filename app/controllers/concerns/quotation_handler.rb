# frozen_string_literal: true

module QuotationHandler
  extend ActiveSupport::Concern

  def load_clients
    unless params[:client].present?
      if can?(:see_all, Client)
        @clients = Client.all
      elsif current_user.structure.present?
        client_ids = ClientUser.where(user_id: current_user.structure.subtree.pluck(:user_id)).pluck(:client_id)
        @clients = Client.where(id: client_ids)
        @sellers = User.can_reserve.where(id: current_user.structure.subtree.pluck(:user_id), is_active: true).order(created_at: :desc)
      else
        client_ids = ClientUser.where(user_id: current_user.id).pluck(:client_id)
        @clients = Client.where(id: client_ids)
      end

      @clients = @clients.includes(:user).search(params).order(created_at: :desc).paginate(page: params[:page], per_page: @per_page)
    end
  end

  def validate_access
    redirect_to root_url, flash: { error: "No tiene permisos para generar una cotización" } if cannot?(:quote, :quote)

    if cannot?(:create, Stage) && current_user.present?
      stage_users = StageUser.where(user: current_user)
      stages = Stage.where(stage_users: stage_users, active: true).includes(:lots).order(order: :asc)
      redirect_to root_url, flash: { error: "No tiene permisos para generar una cotización" } unless stages.pluck(:id).include?(@stage.id)
    end

    if params[:folder].present?
      @folder = Folder.find_by!(id: params[:folder])
      @step_role = @folder&.step&.step_roles&.find_by(role: current_user.role)

      folder_without_active_payments = @folder.installments.includes(:payments).where(payments: { status: :active }).count <= 0

      can_custom_quote = folder_without_active_payments && @step_role&.update_financial?

      unless @folder.present? && @lot.id == @folder.lot_id && can_custom_quote
        redirect_to folders_path, flash: { error: "No tiene permisos para editar la cotización" }
      end
    end

    @unique_folder = Folder.find_by(lot_id: @lot.id, status: %w[active revision approved]).nil?
  end

  def validate_reserve_with_file
    if @folder.nil? && @stage.credit_scheme.requires_file && params[:file].nil?
      respond_to do |format|
        format.js { render @reserve, locals: { error: "no_file" } }
        format.html do
          redirect_to "#{original_fullpath}?client=#{params[:client]}", error: "Para poder reservar es necesario adjuntar el #{@stage.credit_scheme.document_template.name}."
        end
      end
    end
  end

  def set_lot_and_relatives
    if self.instance_of? AvailabilityController
      @lot = Lot.find(params[:id])
      @stage = @lot.stage
      @phase = @stage.phase
      @project = @phase.project
    else
      @project = Project.find(params[:project_id])
      @phase = @project.phases.find(params[:phase_id])
      @stage = @phase.stages.find(params[:stage_id])
      @lot = @stage.lots.find(params[:id])
    end
    @custom_quote_permissions = can?(:custom_discount, :quote) || can?(:custom_buy_price, :quote) || can?(:custom_zero_rate, :quote) ||
        can?(:custom_start_installments, :quote) || can?(:custom_promotion, :quote) || can?(:custom_credit, :quote) ||
        can?(:custom_first_payment, :quote) || can?(:custom_down_payment_finance, :quote) || can?(:custom_down_payment_amount, :quote) ||
        can?(:custom_initial_payment, :quote) || can?(:custom_approved_date, :quote) || can?(:custom_start_date, :quote) || can?(:custom_commissionable, :quote)
  end

  def set_quotation(user)
    @folder = Folder.includes(:payment_scheme, :client).find_by(id: params[:folder])

    @promotions = @stage.promotions.with_size(@lot.area).in_dates(Time.zone.now.to_date).active.order("name", "amount")
    @promotions_to_select = @promotions.left_outer_joins(:coupons)
                                       .where(draft: false)
                                       .where("coupons.promotion_id IS NULL")
    @promotions_including_expired = @stage.promotions.left_outer_joins(:coupons)
                                          .where(draft: false)
                                          .where("coupons.promotion_id IS NULL")
    @promotions_with_active_coupons = @folder.present? ? @stage.promotions.includes(:coupons).where(draft: false, coupons: { status: :active }) : @promotions.includes(:coupons).where(draft: false, coupons: { status: :active })

    @discounts = Discount.where(stage: @stage, is_active: true).order(total_payments: :asc)
    @second_payment = @stage.credit_scheme.second_payment

    if user&.role&.quote_role.present? && user&.role&.quote_role&.min_days_first_monthly_payment.present?
      @min_days_for_first_payment = user.role.quote_role.min_days_first_monthly_payment
    else
      @min_days_for_first_payment = 0
    end

    if user&.role&.quote_role.present? && user&.role&.quote_role&.min_days_first_monthly_payment.present?
      @min_days_for_second_payment = user.role.quote_role.min_days_first_monthly_payment
    else
      @min_days_for_second_payment = 0
    end

    min_and_max_days_of_first_monthly_payment_are_nil = user&.role&.quote_role&.min_days_first_monthly_payment.nil? && user&.role&.quote_role&.max_days_first_monthly_payment.nil?

    if user&.role&.quote_role.nil? || min_and_max_days_of_first_monthly_payment_are_nil
      @max_days_for_first_payment = @stage&.credit_scheme&.first_payment
    elsif user&.role&.quote_role.max_days_first_monthly_payment.present?
      @max_days_for_first_payment = user.role.quote_role.max_days_first_monthly_payment
    else
      @max_days_for_first_payment = nil
    end

    min_and_max_days_of_second_monthly_payment_are_nil = user&.role&.quote_role&.min_days_second_monthly_payment.nil? && user&.role&.quote_role&.max_days_second_monthly_payment.nil?

    if user&.role&.quote_role.nil? || min_and_max_days_of_second_monthly_payment_are_nil
      @max_days_for_second_payment = @stage&.credit_scheme&.second_payment
    elsif user&.role&.quote_role.max_days_first_monthly_payment.present?
      @max_days_for_second_payment = user.role.quote_role.max_days_second_monthly_payment
    else
      @max_days_for_second_payment = nil
    end

    if params[:first_payment].nil?
      @first_payment = @folder.present? ? @folder.payment_scheme.first_payment : @stage.credit_scheme.first_payment
    else
      @first_payment = params[:first_payment].to_f
    end

    @first_payment ||= 0

    if params[:second_payment].nil?
      @second_payment = @folder.present? ? @folder.payment_scheme.second_payment : @second_payment
    else
      @second_payment = params[:second_payment].to_f
    end

    @second_payment ||= 0

    if @folder.present?
      @client = @folder.client
    else
      @client = Client.find_by(id: params[:client])
    end

    if params[:promotion].present?
      terms = params[:total_payments].to_i || 180
      downpayment_terms = params[:down_payment_finance].to_i || 1

      @promotion = @folder.present? ? @promotions_including_expired.select { |promotion| promotion.id == params[:promotion].to_i }.first : @promotions.select { |promotion| promotion.id == params[:promotion].to_i }.first

      if @promotion.nil?
        @promotion_valid = false
        @promotion_error = "La promoción elegida no es válida."
      else
        if @promotion.valid(area: @lot.area, terms: terms, downpayment_terms: downpayment_terms)
          @promotion_valid = true
          @max_days_for_first_payment = @promotion.max_days_for_first_payment.to_i if @promotion.max_days_for_first_payment.present?
        else
          @promotion_valid = false
          @promotion_error = @promotion.description
        end
      end

    elsif can?(:custom_promotion, :quote) && @folder.present?
      @promotion = Promotion.new(
        amount: @custom_promotion.present? ? @folder.payment_scheme.promotion_discount : 0,
        name: @custom_promotion_name.present? ? @folder.payment_scheme.promotion_name : nil,
        operation: @custom_promotion_name.present? ? @folder.payment_scheme.promotion_operation : 0)
    end

    if params[:promotion_code].present?
      terms = params[:total_payments].to_i || 180
      downpayment_terms = params[:down_payment_finance].to_i || 1

      promotion_code = params[:promotion_code].gsub(/\s+/, "")

      coupon = Coupon.lock.find_by(promotion_code: promotion_code)
      @coupons = Coupon.includes(:promotion).where(status: :active, promotions: { active: true }).usable

      if coupon.present?
        coupon_is_in_coupons = @coupons.include?(coupon)
        promotion_coupon_is_in_promotions = @folder.present? ? @promotions_with_active_coupons.include?(coupon.promotion) : @promotions.include?(coupon.promotion)
      end

      if coupon.nil? || !coupon_is_in_coupons || !promotion_coupon_is_in_promotions
        @promotion_coupon_valid = false
        @promotion_coupon_error = "El cupón escrito no es válido."
      else
        if coupon.promotion.valid(area: @lot.area, terms: terms, downpayment_terms: downpayment_terms)
          @promotion_coupon_valid = true
          @max_days_for_first_payment = coupon.promotion.max_days_for_first_payment.to_i if coupon.promotion.max_days_for_first_payment.present?
          @coupon = coupon
        else
          @promotion_coupon_valid = false
          @promotion_coupon_error = coupon.promotion.description
        end
      end

    end

    quote_role_rules = user&.role&.quote_role

    if quote_role_rules.present? && quote_role_rules.min_months_deferred_down_payment.present? && !quote_role_rules.min_months_deferred_down_payment.zero?
      @min_months_for_deferred_down_payment = quote_role_rules.min_months_deferred_down_payment
    else
      @min_months_for_deferred_down_payment = 1
    end

    if @stage.credit_scheme.is_relative_financing && @stage.delivery_date.present?
      @max_months_for_deferred_down_payment = 1
    elsif @stage.credit_scheme.relative_down_payment
      @max_months_for_deferred_down_payment = @stage.months_to_delivery
    elsif quote_role_rules.present? && quote_role_rules.max_months_deferred_down_payment.present?
      @max_months_for_deferred_down_payment = quote_role_rules.max_months_deferred_down_payment
    elsif quote_role_rules.present? && quote_role_rules.min_months_deferred_down_payment.present? || can?(:custom_down_payment_finance, :quote)
      @max_months_for_deferred_down_payment = Float::INFINITY
    else
      @max_months_for_deferred_down_payment = @stage.down_payment_max_finance
    end

    greater_than_max_months = @max_months_for_deferred_down_payment.nil? ? false : params[:down_payment_finance].to_i > @max_months_for_deferred_down_payment
    less_than_min_months = params[:down_payment_finance].to_i < @min_months_for_deferred_down_payment
    @down_payment_deferred_months_error = true if greater_than_max_months || less_than_min_months

    greater_than_max_days = @max_days_for_first_payment.nil? ? false : @first_payment > @max_days_for_first_payment
    less_than_min_days = @first_payment < @min_days_for_first_payment
    @first_payment_error = true if (greater_than_max_days || less_than_min_days) && (cannot?(:custom_first_payment, :quote) || (can?(:custom_first_payment, :quote) && @folder.nil?))

    second_greater_than_max_days = @max_days_for_second_payment.nil? ? false : @second_payment > @max_days_for_second_payment
    second_less_than_min_days = @second_payment < @min_days_for_second_payment
    @second_payment_error = true if (second_greater_than_max_days || second_less_than_min_days) && @folder.nil?

    @promotion ||= Promotion.new

    @relative_plans = get_relative_plans @lot
  end

  def generate(with_amortization: true)
    @total_periods = @stage.credit_scheme.periods.inject(0) { |sum, period| sum + period.payments }

    if params[:total_payments].present?
      @total_payments = params[:total_payments].to_i
    else
      @total_payments = @folder.present? ? @folder.payment_scheme.total_payments : default_total_payments(@total_periods, @stage)
    end

    if @stage.credit_scheme.is_relative_financing && @stage.delivery_date.present?
      @total_payments, @total_periods = @stage.months_to_relative_financing if  @stage.months_to_relative_financing < @total_payments
    end

    @relative_plan = get_relative_plan(@total_payments, @lot)
    @discount = @relative_plan[:discount]
    date = Time.zone.now
    start_installments = @stage.credit_scheme.start_installments
    zero_rate_extra = 0

    if can?(:custom_area, :quote) && @folder.present?
      @lot_area = params[:custom_area].presence&.to_f
    end

    @lot_area ||= @lot.area

    if can?(:custom_buy_price, :quote) && @folder.present? && @lot.fixed_price.blank?
      price_with_additional = @folder.payment_scheme.buy_price
      if params[:custom_buy_price].present?
        @lot_price = @lot_area * params[:custom_buy_price].to_f
      elsif @folder.present?
        @lot_price = @lot_area * @folder.payment_scheme.buy_price
      end
    end

    price_with_additional ||= @lot.price_with_additional

    if @promotion_valid && @promotion.present?
      start_installments = @promotion.start_installments
      zero_rate_extra = @promotion.zero_rate_extra
    end

    if @promotion_coupon_valid && @coupon.present?
      start_installments = @coupon.promotion.start_installments
      zero_rate_extra = @coupon.promotion.zero_rate_extra
    end

    if @lot.stage.credit_scheme.simple_interest?
      buy_price = calculate_buy_price_with_periods(@total_payments, price_with_additional, @lot.stage.credit_scheme.periods, zero_rate_extra)
      @lot_price = @lot_area * buy_price
    else
      @lot_price ||= @lot_area * price_with_additional
    end

    @lot_price = @lot.fixed_price unless @lot.fixed_price.blank?

    validate_down_payment(promotion: @promotion, promotion_valid: @promotion_valid, lot_price: @lot_price, coupon: @coupon, promotion_coupon_valid: @promotion_coupon_valid)

    @simple_quotations = simple_quotations @relative_plans, @lot, @lot_area, zero_rate_extra, promotion: @promotion, down_payment: @min_downpayment_price, price: @lot_price, use_compound_interest: @stage.credit_scheme.multiple_periods?

    immediate_extra_months = is_immediate_construction? ? @stage.credit_scheme.immediate_extra_months : 0

    @relative_down_payment = @stage.credit_scheme.relative_down_payment
    @delivery_date = @stage.delivery_date
    @independent_initial_payment = @stage.credit_scheme.independent_initial_payment
    @initial_payment_active = @stage.credit_scheme.initial_payment_active

    @custom_quote = custom_quote(
      buy_price: price_with_additional,
      discount: @discount,
      date: date,
      first_payment: @first_payment,
      start_installments: start_installments,
      zero_rate: nil,
      down_payment: @down_payment_amount,
      initial_payment: @initial_payment,
      down_payment_finance: @down_payment_finance,
      credit_scheme: @stage.credit_scheme
    )

    validate_last_payment

    @total_periods = @custom_quote.credit_scheme.periods.inject(0) { |sum, period| sum + period.payments }

    if @custom_quote.credit_scheme.is_relative_financing && @stage.delivery_date.present?
      @total_periods = @stage.months_to_relative_financing
    end

    @custom_promotion_coupon = custom_promotion_coupon

    @quotation = generate_amortization(
      price: @lot_price,
      area: @lot_area,
      start_date: @lot.stage.release_date,
      date: @custom_quote.date,
      total_payments: @total_payments,
      down_payment_total_payments: @custom_quote.down_payment_finance,
      discount: @custom_quote.discount,
      buy_price: @custom_quote.buy_price,
      initial_payment: @custom_quote.initial_payment,
      complement_payment: @complement_payment,
      down_payment: @custom_quote.down_payment,
      first_payment: @custom_quote.first_payment,
      exclusive_promotion: @custom_quote.promotion,
      exclusive_promotion_operation: @custom_quote.promotion_operation,
      promotion: @custom_promotion_coupon.promotion,
      promotion_operation: @custom_promotion_coupon.promotion_operation,
      coupon: @custom_promotion_coupon.coupon,
      coupon_operation: @custom_promotion_coupon.coupon_operation,
      start_installments: @custom_quote.start_installments,
      zero_rate: @custom_quote.zero_rate,
      zero_rate_extra: zero_rate_extra,
      credit_scheme: @custom_quote.credit_scheme.periods.order(order: :ASC),
      immediate_extra_months: immediate_extra_months,
      project_type: @project.quotation,
      relative_discount: @lot.stage.credit_scheme.relative_discount,
      expire_months: @lot.stage.credit_scheme.expire_months,
      with_amortization: with_amortization,
      relative_down_payment: @custom_quote.credit_scheme.relative_down_payment,
      consider_residue_in_down_payments: @custom_quote.credit_scheme.consider_residue_in_down_payments,
      independent_initial_payment: @independent_initial_payment,
      delivery_date: @delivery_date,
      second_payment: @second_payment,
      initial_payment_active: @initial_payment_active,
      quotation_type: @custom_quote.credit_scheme.quotation_type,
      with_last_payment: @custom_quote.credit_scheme.has_last_payment,
      last_payment_amount: @last_payment_amount,
      is_relative_financing: @custom_quote.credit_scheme.is_relative_financing
    )

    if can?(:reserve, :quote)
      @quote_log = QuoteLog.find_or_create_by(lot_id: @lot.id, client: @client, user_id: current_user.id, creation_date: date)
    end

    if !@stage.credit_scheme.independent_initial_payment && @quotation.initial_payment <= @quotation.down_payment_monthly_payment && @quotation.initial_payment < @stage.credit_scheme.initial_payment
      @initial_payment_price_error = false
    end

    @credit_scheme = @custom_quote.credit_scheme

    set_totals
  end

  def validate_down_payment(promotion: Promotion.new, promotion_valid: false, lot_price:, coupon: nil, promotion_coupon_valid: false)
    @down_payment_editable = @stage.credit_scheme.down_payment_editable
    @initial_payment_editable = @stage.credit_scheme.initial_payment_editable

    if @stage.credit_scheme.lock_payment == 0
      @min_initial_payment = @stage.credit_scheme.initial_payment
    else
      @min_initial_payment = @stage.credit_scheme.lock_payment
    end

    discount = @custom_discount.present? ? @custom_discount.to_f / 100 : @discount
    exclusive_promotion_amount = @custom_promotion.present? ? @custom_promotion.to_f / 100 : 0
    exclusive_promotion_operation = @custom_promotion_operation if @custom_promotion_operation.present?

    promotion_amount = promotion.present? ? promotion.amount : 0
    promotion_discount_type = promotion.present? ? promotion.discount_type : 0
    promotion_operation = promotion.present? ? promotion.operation : nil

    promotion_coupon_amount = coupon.present? ? coupon.promotion.amount : 0
    promotion_coupon_operation = coupon.present? ? coupon.promotion.operation : nil

    @actual_down_payment_finance = params[:down_payment_finance].present? ? params[:down_payment_finance] : @min_months_for_deferred_down_payment
    @actual_down_payment_finance = 1 if @actual_down_payment_finance.to_i <= 0 || @stage.credit_scheme.is_relative_financing && @stage.delivery_date.present?

    @min_down_payment = get_min_down_payment(@actual_down_payment_finance, @lot)
    price = promotion_calculator(lot_price, discount, exclusive_promotion_amount, exclusive_promotion_operation, promotion_amount, promotion_operation, promotion_coupon_amount, promotion_coupon_operation, promotion_discount_type)
    @price_with_discount = price.total
    @min_initialpayment_price = @stage.credit_scheme.initial_payment
    @min_initialpayment_price = @stage.credit_scheme.lock_payment if @stage.credit_scheme.lock_payment > 0
    @min_downpayment_price = @price_with_discount * (@min_down_payment / 100)
    @max_downpayment_price = @price_with_discount

    if @stage.credit_scheme.initial_payment_active && @min_downpayment_price < @stage.credit_scheme.initial_payment
      @min_downpayment_price = @stage.credit_scheme.initial_payment
    end

    if promotion_valid && promotion.present? && promotion.persisted?
      @down_payment_editable = promotion.downpayment_editable
      if promotion.downpayment_amount.present?
        if promotion.downpayment_type == "percentage"
          @min_downpayment_price = @price_with_discount * (promotion.downpayment_amount / 100)
        else
          @min_downpayment_price = promotion.downpayment_amount
        end
      end

      @initial_payment_editable = promotion.initialpayment_editable
      if promotion.initialpayment_amount.present?
        if promotion.initialpayment_type == "percentage"
          @min_initialpayment_price = @price_with_discount * (promotion.initialpayment_amount / 100)
        else
          @min_initialpayment_price = promotion.initialpayment_amount
        end
      end
    else
      @down_payment_default = @min_down_payment
    end

    if promotion_coupon_valid && coupon.present? && coupon.persisted?
      @down_payment_editable = coupon.promotion.downpayment_editable
      if coupon.promotion.downpayment_amount.present?
        if coupon.promotion.downpayment_type == "percentage"
          @min_downpayment_price = @price_with_discount * (coupon.promotion.downpayment_amount / 100)
        else
          @min_downpayment_price = coupon.promotion.downpayment_amount
        end
      end

      @initial_payment_editable = coupon.promotion.initialpayment_editable
      if coupon.promotion.initialpayment_amount.present?
        if coupon.promotion.initialpayment_type == "percentage"
          @min_initialpayment_price = @price_with_discount * (coupon.promotion.initialpayment_amount / 100)
        else
          @min_initialpayment_price = coupon.promotion.initialpayment_amount
        end
      end
    else
      @down_payment_default = @min_down_payment
    end

    @min_downpayment_percentage = @min_downpayment_price / @price_with_discount
    @max_downpayment_percentage = @max_downpayment_price / @price_with_discount

    if params[:down_payment_finance].present?
      finance = @stage.credit_scheme.is_relative_financing && @stage.delivery_date.present? ? 1 : params[:down_payment_finance].to_i

      max_finance = @max_months_for_deferred_down_payment
      max_finance ||= @stage.credit_scheme.max_finance

      if @stage.credit_scheme.relative_down_payment && @stage.delivery_date.present?
        @down_payment_finance = finance.between?(1, @stage.months_to_delivery) ? finance : 1
      else
        @down_payment_finance = (@stage.credit_scheme.max_finance.present? && finance.between?(1, max_finance)) ? finance : 1
      end
    else
      @down_payment_finance = @min_months_for_deferred_down_payment
    end

    if params[:payment_way].present? && ["percentage", "amount"].include?(params[:payment_way]) && params[:down_payment_amount].present? && (@down_payment_editable || @custom_quote_permissions)
      @payment_way = params[:payment_way]
      if @payment_way == "percentage"
        @down_payment_amount = @price_with_discount * (params[:down_payment_amount].to_f / 100)
      else
        @down_payment_amount = params[:down_payment_amount].to_f
      end

      unless @down_payment_amount.to_f.between?(@min_downpayment_price.to_f, @max_downpayment_price.to_f)
        @downpayment_price_error = true if cannot?(:custom_down_payment_amount, :quote) || (can?(:custom_down_payment_amount, :quote) && @folder.nil?)
        if @down_payment_amount < @min_downpayment_price && (cannot?(:custom_down_payment_amount, :quote) || (can?(:custom_down_payment_amount, :quote) && @folder.nil?))
          @down_payment_amount = @min_downpayment_price
        elsif @down_payment_amount > @max_downpayment_price
          @down_payment_amount = @max_downpayment_price
        end
      end
    else
      @payment_way = "amount"
      if @folder.present? && can?(:custom_down_payment_amount, :quote)
        @down_payment_amount = @folder.payment_scheme.down_payment + @folder.payment_scheme.initial_payment
      else
        @down_payment_amount = @min_downpayment_price
      end
    end

    if params[:initial_payment].present? && (@initial_payment_editable || @custom_quote_permissions)
      @initial_payment = params[:initial_payment].to_f
      if @initial_payment.between?(@min_initialpayment_price, @down_payment_amount)
        if @initial_payment < @stage.credit_scheme.initial_payment && @stage.credit_scheme.lock_payment > 0
          @complement_payment = (@stage.credit_scheme.initial_payment - @initial_payment)
          @initial_payment = @stage.credit_scheme.initial_payment
        end
      else
        @initial_payment_price_error = true if cannot?(:custom_initial_payment, :quote) || can?(:custom_initial_payment, :quote) && @folder.nil?
        if @initial_payment < @min_initialpayment_price && (cannot?(:custom_initial_payment, :quote) || (can?(:custom_initial_payment, :quote) && @folder.nil?))
          @initial_payment = @min_initialpayment_price
        elsif @initial_payment > @down_payment_amount
          @initial_payment = @down_payment_amount
        end
      end
    else
      if @folder.present? && can?(:custom_initial_payment, :quote)
        @initial_payment = @folder.payment_scheme.initial_payment
      else
        @initial_payment = @min_initialpayment_price
      end
    end
  end

  def validate_last_payment
    @last_payment_error = false
    credit_scheme = @custom_quote.credit_scheme
    @has_min_last_payment = credit_scheme.has_last_payment
    @min_last_payment_amount = credit_scheme.min_last_payment_amount
    @min_last_payment_payment_way = credit_scheme.min_last_payment_payment_way
    is_last_payment_percentage = is_percentage(@min_last_payment_payment_way)
    down_payment_percentage = calculate_to_percentage(is_percentage(@payment_way), @down_payment_amount, @price_with_discount)

    set_last_payment_calulation(is_last_payment_percentage, @min_last_payment_amount, @price_with_discount, down_payment_percentage)

    if params[:min_last_payment_payment_way].present? && params[:min_last_payment_amount].present?
      set_user_last_payment(params[:min_last_payment_payment_way], params[:min_last_payment_amount].to_f)
    end

    if @has_min_last_payment && !@last_payment_percentage.between?(@min_last_payment_percentage, @max_last_payment_percentage)
      @last_payment_error = true
    end
  end

  def set_last_payment_calulation(is_last_payment_percentage, min_last_payment_amount, price_with_discount, down_payment_percentage)
    @min_last_payment_percentage = calculate_to_percentage(is_last_payment_percentage, min_last_payment_amount, price_with_discount)
    @max_last_payment_percentage = 1 - down_payment_percentage

    @last_payment_percentage = @min_last_payment_percentage
    @last_payment_amount = calculate_to_amount(is_last_payment_percentage, min_last_payment_amount, price_with_discount)
  end

  def set_user_last_payment(min_last_payment_payment_way, min_last_payment_amount)
    @min_last_payment_payment_way = min_last_payment_payment_way

    is_last_payment_percentage = is_percentage(min_last_payment_payment_way)
    @last_payment_percentage = calculate_to_percentage(is_last_payment_percentage, min_last_payment_amount, @price_with_discount)
    @last_payment_amount = calculate_to_amount(is_last_payment_percentage, min_last_payment_amount, @price_with_discount)
  end

  def custom_quote(discount:, first_payment:, promotion: 0, promotion_operation: nil, promotion_name: nil, promotion_commissionable: true, date: nil, buy_price: nil, start_installments: nil, zero_rate: nil, down_payment:, initial_payment:, down_payment_finance:, credit_scheme: nil)
    if @folder.present? && can?(:custom_start_installments, :quote)
      if @custom_down_payment_differ.present? && @custom_start_installments.present? && @custom_start_installments.to_i > 0
        actual_start_installments = @custom_start_installments.to_i
      elsif @custom_down_payment_differ.present? && @custom_start_installments.present? && @custom_start_installments.to_i < 1
        actual_start_installments = nil
      elsif @custom_down_payment_differ.present? && @custom_start_installments.nil?
        actual_start_installments = start_installments
      elsif @custom_down_payment_differ.nil?
        actual_start_installments = nil
      end
    else
      actual_start_installments = start_installments
    end

    CustomQuote.new(
      date: @custom_start_date.present? ? @custom_start_date.to_date : date,
      discount: @custom_discount.present? ? @custom_discount.to_f / 100 : discount,
      buy_price: @custom_buy_price.present? && @lot.fixed_price.blank? ? @custom_buy_price.to_f : buy_price,
      first_payment: @custom_first_payment.present? ? @custom_first_payment.to_i : first_payment,
      start_installments: actual_start_installments,
      zero_rate: @custom_zero_rate.present? ? @custom_zero_rate.to_i : zero_rate,
      promotion: @custom_promotion.present? ? @custom_promotion.to_f / 100 : promotion,
      promotion_operation: @custom_promotion_operation.present? ? @custom_promotion_operation : promotion_operation,
      promotion_name: @custom_promotion_name.present? ? @custom_promotion_name : promotion_name,
      down_payment: @custom_down_payment.present? ? @custom_down_payment : down_payment,
      initial_payment: @custom_initial_payment.present? ? @custom_initial_payment : initial_payment,
      down_payment_finance: @custom_down_payment_finance.present? ? @custom_down_payment_finance : down_payment_finance,
      credit_scheme: @custom_credit.present? ? CreditScheme.find(@custom_credit) : credit_scheme,
      is_commissionable: @custom_commissionable.nil? ? promotion_commissionable : @custom_commissionable,
        )
  end

  def custom_promotion_coupon(promotion_amount: 0, promotion_operation: nil, promotion_discount_type: nil, coupon_promotion_amount: 0, coupon_promotion_operation: nil)
    CustomPromotionCoupon.new(
      promotion: @promotion.present? ? @promotion.amount : promotion_amount,
      promotion_discount_type: @promotion.present? ? @promotion.discount_type : promotion_discount_type,
      promotion_operation:  @promotion.present? ? @promotion.operation : promotion_operation,
      coupon:  @coupon.present? ? @coupon.promotion.amount : coupon_promotion_amount,
      coupon_operation: @coupon.present? ? @coupon.promotion.operation : coupon_promotion_operation
    )
  end

  def set_custom_data
    if @folder.present?
      @custom_start_date = params[:custom_start_date].present? ? params[:custom_start_date].to_date.strftime("%d/%m/%Y") : @folder.calc_date.strftime("%d/%m/%Y")
      if can?(:custom_discount, :quote)
        @custom_discount = params[:custom_discount] || @folder.payment_scheme.discount * 100
      end

      if can?(:custom_buy_price, :quote)
        @custom_buy_price = params[:custom_buy_price] || @folder.payment_scheme.buy_price
      end

      if can?(:custom_zero_rate, :quote)
        @custom_zero_rate = params[:custom_zero_rate] || @folder.payment_scheme.zero_rate
      end

      if can?(:custom_start_installments, :quote)
        @custom_start_installments = params[:custom_start_installments]
        @custom_down_payment_differ = params[:custom_down_payment_differ]
      end

      if can?(:custom_promotion, :quote)
        @custom_promotion = params[:custom_promotion] || @folder.payment_scheme.promotion_discount * 100
        @custom_promotion_operation = params[:custom_promotion_operation] || @folder.payment_scheme.promotion_operation
        @custom_promotion_name = params[:custom_promotion_name] || @folder.payment_scheme.promotion_name
        @promotion = @promotions_including_expired.select { |promotion| promotion.id == params[:promotion].to_i }.first || @folder.payment_scheme.promotion
        @coupon = @coupon || @folder.payment_scheme.coupon
      end

      if can?(:custom_credit, :quote)
        @custom_credit = params[:custom_credit] || @folder.payment_scheme.credit_scheme_id
      end

      if can?(:custom_first_payment, :quote)
        @custom_first_payment = @folder.payment_scheme.first_payment if params[:first_payment].nil?
      end

      if can?(:custom_down_payment, :quote)
        @custom_down_payment = @folder.payment_scheme.down_payment + @folder.payment_scheme.initial_payment if params[:down_payment_amount].nil?
      end

      if can?(:custom_initial_payment, :quote)
        @custom_initial_payment = @folder.payment_scheme.initial_payment if params[:initial_payment].nil?
      end

      if can?(:custom_down_payment_finance, :quote)
        @custom_down_payment_finance = params[:down_payment_finance].nil? ? @folder.payment_scheme.down_payment_finance : params[:down_payment_finance].to_i
      end

      if can?(:custom_commissionable, :quote)
        @custom_commissionable = params[:custom_commissionable].present?
      end

    end
  end

  def set_totals
    @capital_total = @quotation.amr.inject(0) { |sum, payment| sum + payment[:capital] }
    @interest_total = @quotation.amr.inject(0) { |sum, payment| sum + payment[:interest] }
    @payment_total = @quotation.amr.inject(0) { |sum, payment| sum + payment[:payment] }

    if @quotation.is_down_payment_differ
      @down_payment_total = @quotation.down_payment_monthly_payments.inject(0) { |sum, payment| sum + payment[:payment].round(2) }
      @payment_total += @down_payment_total
      @down_payment_total += @quotation.amr.inject(0) { |sum, payment| sum + payment[:down_payment].round(2) }
    else
      @down_payment_total = @quotation.down_payment_monthly_payments.inject(0) { |sum, payment| sum + payment[:payment] }
      @payment_total += @down_payment_total
    end
  end

  def encode_base_64(element)
    Base64.encode64(element.to_s)
  end

  def file_to_load
    @pdf = "quotes/new_format/pdf.html.erb"
    @file = "quotes/quote"
    @reserve = "quotes/reserve"
  end

  def is_immediate_construction?
    params[:is_immediate_construction] || false
  end

  def set_max_commission_amount(total_payments, max_commission_amount)
    return 0 if max_commission_amount.nil?
    return total_payments if total_payments <= max_commission_amount
    max_commission_amount
  end

  def default_total_payments(total_payments, stage)
    default_payment = stage.credit_scheme.default_payment
    if default_payment.present? && default_payment > 0 && default_payment < total_payments
      total_payments = default_payment
    end
    total_payments
  end

  def is_percentage(payment_way)
    payment_way == "percentage"
  end

  def calculate_to_percentage(is_percentage, amount, total_base)
    is_percentage ? (amount / 100) : (amount / total_base)
  end

  def calculate_to_amount(is_percentage, amount, total_base)
    is_percentage ? total_base * (amount / 100) : amount
  end
end
