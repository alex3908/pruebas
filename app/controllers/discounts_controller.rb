# frozen_string_literal: true

class DiscountsController < ApplicationController
  include EntityNamesConcern
  before_action :set_credit_scheme, only: [:index, :show, :edit, :new, :create, :update, :destroy]
  load_and_authorize_resource

  # GET /discounts
  def index
    @discounts = Discount.where(credit_scheme: @credit_scheme).order(total_payments: :asc).paginate(page: params[:page], per_page: @per_page)
  end

  # GET /discounts/1
  def show
  end

  # GET /discounts/new
  def new
    @discount = Discount.new
  end

  # GET /discounts/1/edit
  def edit
    @discount.discount = @discount.discount * 100
  end

  # POST /discounts
  def create
    @is_duplicated = Discount.where(credit_scheme: @credit_scheme, total_payments: @discount.total_payments).count > 0

    if @is_duplicated
      redirect_to new_credit_scheme_discount_path(@credit_scheme), warning: "Ya existe un descuento con ese límite."
    else
      @discount.credit_scheme = @credit_scheme

      case @discount.total_payments
      when 1
        @discount.name = "Contado"
      else
        @discount.name = "#{@discount.total_payments} meses"
      end

      if @discount.save
        redirect_to credit_scheme_discounts_path(@credit_scheme), success: "Plan de pagos creado correctamente."
      else
        render :new
      end
    end
  end

  # PATCH/PUT /discounts/1
  def update
    @is_duplicated = Discount.where.not(id: @discount.id).where(credit_scheme: @credit_scheme, total_payments: params[:discount][:total_payments]).count > 0

    if @is_duplicated
      redirect_to edit_credit_scheme_discount_path(@credit_scheme), warning: "Ya existe un descuento con ese límite."
    else
      case params[:discount][:total_payments]
      when 1
        @discount.name = "Contado"
      else
        @discount.name = "#{params[:discount][:total_payments]} meses"
      end

      if @discount.update(discount_params)
        redirect_to credit_scheme_discounts_path(@credit_scheme), success: "Plan de pagos actualizado correctamente."
      else
        render :edit
      end
    end
  end

  # DELETE /discounts/1
  def destroy
    @discount.destroy
    redirect_to credit_scheme_discounts_path(@credit_scheme), success: "Plan de pagos eliminado correctamente."
  end

  # PATCH /discounts/1/activate_discount
  def activate_plan
    @discount = Discount.find(params[:id])
    @discount.toggle!(:is_active)
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_credit_scheme
      @credit_scheme = CreditScheme.find(params[:credit_scheme_id])
    end

    def set_stage
      @stage = @phase.stages.find(params[:stage_id])
    end

    def set_phase
      @phase = @project.phases.find(params[:phase_id])
    end

    def set_project
      @project = Project.find(params[:project_id])
    end

    def discount_params
      params.require(:discount).permit(:name, :down_payment, :discount, :total_payments, :dfp, :is_active)
    end
end
