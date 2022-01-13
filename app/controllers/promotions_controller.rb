# frozen_string_literal: true

class PromotionsController < ApplicationController
  load_and_authorize_resource except: [:activate]
  helper_method :sort_column, :sort_direction

  # GET /promotions
  # GET /promotions.json
  def index
    @per_page = params[:per_page].to_i < 1 ? 10 : params[:per_page] || 10
    order = params.has_key?(:sort) || params.has_key?(:direction) ? sort_column + " " + sort_direction : "active desc, end_date asc" # By default, it shows active promotions by end date to see if any are about to expire.
    @promotions = Promotion.search(params).order(order).paginate(page: params[:page], per_page: @per_page).order(id: :asc)
  end

  # GET /promotions/1
  # GET /promotions/1.json
  def show
    @per_page = params[:per_page].to_i < 1 ? 10 : params[:per_page] || 10
    @stages = Stage.includes(phase: :project).paginate(page: params[:page], per_page: @per_page).set_params(params, "projects.id", sort_direction)
    @projects = Project.includes(phases: :stages).order(id: :asc)
    promotion = Promotion.find_by! id: params[:id]
    @filter_path = promotion_path(promotion)
  end

  def activate
    raise CanCan::AccessDenied.new("No tienes permisos para activar esta promoción") unless can?(:update, Promotion)
    status = (params[:status] == "true")
    stage = Stage.find_by! id: params[:stage]
    promotion = Promotion.find_by! id: params[:id]

    if status && !stage.has_promotion(promotion)
      stage.promotions << promotion
    elsif !status && stage.has_promotion(promotion)
      stage.promotions.delete(promotion)
    end


    respond_to do |format|
      if stage.save!
        format.html { redirect_to promotions_path(promotion), notice: "Promoción activada correctamente." }
        format.js
        format.json { render json: promotion, status: :ok, location: promotion }
      else
        format.html redirect_to promotions_path(promotion), notice: "Hubo un error al intentar hacer el cambio."
        format.js
        format.json { render json: promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  def activate_promotion
    promotion = Promotion.find(params[:id])

    respond_to do |format|
      if promotion.update(draft: false)
        redirect_to edit_promotion_path, notice: "La promoción se activó correctamente."
        format.js
      end
    end
  end

  # GET /promotions/new
  def new
    @promotion = Promotion.new
  end

  # GET /promotions/1/edit
  def edit
  end

  # POST /promotions
  # POST /promotions.json
  def create
    @promotion = Promotion.new(promotion_params)

    respond_to do |format|
      if @promotion.save
        format.html { redirect_to @promotion, notice: "Promoción creada exitosamente." }
        format.json { render :show, status: :created, location: @promotion }
      else
        format.html { render :new }
        format.json { render json: @promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /promotions/1
  # PATCH/PUT /promotions/1.json
  def update
    params[:promotion][:start_installments] = nil if params[:down_payment_differ].nil?
    respond_to do |format|
      if @promotion.update(promotion_params)
        format.html { redirect_to promotions_url, notice: "Promoción actualizada correctamente." }
        format.json { render :show, status: :ok, location: promotions_url }
      else
        format.html { render :edit }
        format.json { render json: @promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /promotions/1
  # DELETE /promotions/1.json
  def destroy
    @promotion.destroy
    respond_to do |format|
      format.html { redirect_to promotions_url, notice: "Promoción eliminada correctamente." }
      format.json { head :no_content }
    end
  end

  def attributes_to_change
    @promotion.assign_attributes(promotion_params)
    respond_to do |format|
      format.js
    end
  end

  private

    def set_promotion
      @promotion = Promotion.find(params[:id])
    end

    def promotion_params
      params.require(:promotion).permit(:name, :start_date, :end_date, :amount, :min_area, :max_area, :term_min, :term_max, :downpayment_min, :downpayment_max, :downpayment_amount, :downpayment_type, :downpayment_editable, :active, :initialpayment_amount, :initialpayment_type, :initialpayment_editable, :max_days_for_first_payment, :operation, :zero_rate_extra, :start_installments, :is_commissionable, :enabled_coupons, :show_percentage, :discount_type)
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def sort_column
      if Promotion.column_names.include?(params[:sort])
        params[:sort]
      else
        "id"
      end
    end
end
