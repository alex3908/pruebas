# frozen_string_literal: true

class CreditSchemesController < ApplicationController
  load_and_authorize_resource
  before_action :set_document_templates, :set_payment_methods, eonly: [:new, :edit, :update, :create]
  before_action :set_default_discount, :set_default_down_payment, only: [:new]

  # GET /credit_scheme
  def index
    @credit_schemes = @credit_schemes.order(created_at: :desc).paginate(page: params[:page], per_page: @per_page)
  end

  # GET /credit_scheme/1
  def show
  end

  # GET /credit_scheme/new
  def new
  end

  # GET /credit_scheme/1/edit
  def edit
  end

  # POST /credit_scheme
  # POST /credit_scheme.json
  def create
    respond_to do |format|
      if @credit_scheme.save
        format.html { redirect_to :credit_schemes, notice: "Esquema de cr\u00E9dito creado." }
        format.json { render :show, status: :created, location: @credit_scheme }
      else
        format.html { render :new }
        format.json { render json: @credit_scheme.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /credit_scheme/1
  def update
    ActiveRecord::Base.transaction do
      respond_to do |format|
        if @credit_scheme.update(credit_scheme_params)
          format.html { redirect_to :credit_schemes, notice: "El esquema de cr\u00E9dito fue actualizado." }
          format.json { render :show, status: :ok, location: @credit_scheme }
        else
          format.html { render :edit }
          format.json { render json: @credit_scheme.errors, status: :unprocessable_entity }
        end
      end
    end
  rescue ActiveRecord::RecordNotDestroyed => invalid
    error_messages = invalid.record.errors.values.join(",")
    respond_to do |format|
      format.html { redirect_to edit_credit_scheme_path(@credit_scheme), flash: { error: "#{error_messages}" } }
      format.json { render json: invalid.record.errors, status: :unprocessable_entity }
    end
  end

  # DELETE /credit_schemes/:credit_scheme_id
  def destroy
    @credit_scheme.destroy
    redirect_to credit_schemes_path, success: "Esquema de crédito eliminado correctamente."
  end

  def change_status
    if @credit_scheme.stages.count <= 0
      status = @credit_scheme.status ? "desactivado" : "activado"
      @credit_scheme.toggle!(:status)
      redirect_to credit_schemes_path, flash: { success: "El esquema de crédito #{@credit_scheme.name} fue #{status}." }
    else
      redirect_to credit_schemes_path, flash: { warning: "El esquema de crédito #{@credit_scheme.name} no se puede desactivar porque está asignado a #{@credit_scheme.stages.count} etapa(s)." }
    end
  end

  def stages
  end

  def period_max_order
    order = CreditScheme.find(params[:id]).periods.maximum("order").to_i + 1

    respond_to do |format|
       format.json { render json: order }
     end
  end

  private

    def credit_scheme_params
      params.require(:credit_scheme).permit(:name,
                                            :status,
                                            :requires_file,
                                            :default_payment,
                                            :document_template_id,
                                            :first_payment,
                                            :lock_payment,
                                            :initial_payment,
                                            :price,
                                            :min_capital_payment,
                                            :min_down_payment_advance,
                                            :max_grace_months,
                                            :max_delay_payments,
                                            :relative_discount,
                                            :immediate_extra_months,
                                            :max_percent_immediate_lots_sold,
                                            :min_down_payment,
                                            :max_finance,
                                            :start_installments,
                                            :relative_down_payment,
                                            :delivery_date,
                                            :initial_payment_active,
                                            :independent_initial_payment,
                                            :second_payment,
                                            :down_payment_editable,
                                            :initial_payment_editable,
                                            :expire_months,
                                            :surplus_amount_to_capital_time,
                                            :consider_residue_in_down_payments,
                                            :quotation_type,
                                            :has_last_payment,
                                            :min_last_payment_payment_way,
                                            :min_last_payment_amount,
                                            :is_relative_financing,
                                            :reffered_client_amount,
                                            :reffered_client_payment_way,
                                            :payment_method_id,
                                            :is_opening_commission,
                                            :cancellation_balance,
                                            :down_payment_balance,
                                            :principal_balance,
                                            :balance_of_updates,
                                            :opening_commission,
                                            periods_attributes: [
                                                :id,
                                                :payments,
                                                :interest,
                                                :order,
                                                :_destroy
                                                ],
                                            discounts_attributes: [
                                                :id,
                                                :total_payments,
                                                :discount,
                                                :_destroy
                                                ],
                                            down_payments_attributes: [
                                                :id,
                                                :term,
                                                :min,
                                                :_destroy
                                                ]
                                              )
    end

    def set_document_templates
      # TODO: Add SCOPE after polimophic documents are merged
      @document_templates = DocumentTemplate.all
    end

    def set_payment_methods
      @payment_methods = PaymentMethod.for_referred
      @method_down_payment = PaymentMethod.where(down_payment: true)
      @method_payment_capital = PaymentMethod.where(capital: true)
      @method_payment_interest = PaymentMethod.where(interest: true)
    end

    def set_default_discount
      @credit_scheme.discounts << Discount.new(name: "Contado", discount: 0, total_payments: 1, credit_scheme: @credit_scheme)
    end

    def set_default_down_payment
      @credit_scheme.down_payments << DownPayment.new(term: 1, min: 10, credit_scheme: @credit_scheme)
    end
end
