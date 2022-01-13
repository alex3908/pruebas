# frozen_string_literal: true

class CouponsController < ApplicationController
  load_and_authorize_resource :promotion
  load_and_authorize_resource :coupon, through: :promotion

  # GET /coupons
  # GET /coupons.json
  def index
    @coupons = Coupon.where(promotion: @promotion)
  end

  # GET /coupons/1
  # GET /coupons/1.json
  def show
  end

  # GET /coupons/new
  def new
    @coupon = Coupon.new
  end

  # GET /coupons/1/edit
  def edit
  end

  def activate
    coupon = Coupon.find(params[:id])

    if coupon.draft || params[:status] == "true"
      status = Coupon.statuses[:active]
      action_message = "activó"
    else
      status = Coupon.statuses[:deactive]
      action_message = "desactivó"
    end

    respond_to do |format|
      if coupon.update(draft: false, status: status)
        format.html { redirect_to promotion_coupons_path, notice: "El cupón se #{action_message} correctamente." }
        format.json { render :show, status: :ok, location: coupon }
      else
        format.html { render :edit }
        format.json { render json: coupon.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /coupons
  # POST /coupons.json
  def create
    coupon_exist = Coupon.where(promotion_code: @coupon.promotion_code).present?

    if coupon_params.dig(:promotion_code).present?
      @coupon.promotion_code = coupon_params.dig(:promotion_code).gsub(/\s+/, "")
    end

    respond_to do |format|
      if !coupon_exist
        if @coupon.save
          format.html { redirect_to promotion_coupons_path, notice: "El cupón se creo correctamente." }
          format.json { render :show, status: :created, location: @coupon }
        else
          format.html { render :new }
          format.json { render json: @coupon.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to new_promotion_coupon_path(@promotion, @coupon), flash: { error: "El código de promoción ya existe." } }
        format.json { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /coupons/1
  # PATCH/PUT /coupons/1.json
  def update
    if coupon_params.dig(:promotion_code).present?
      params[:coupon][:promotion_code] = coupon_params.dig(:promotion_code).gsub(/\s+/, "")
    end

    respond_to do |format|
      if @coupon.update(coupon_params)
        format.html { redirect_to promotion_coupons_path, notice: "El cupón se actualizó correctamente." }
        format.json { render :show, status: :ok, location: @coupon }
      else
        format.html { render :edit }
        format.json { render json: @coupon.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /coupons/1
  # DELETE /coupons/1.json
  def destroy
    @coupon.destroy
    respond_to do |format|
      format.html { redirect_to promotion_coupons_path, notice: "El cupón se eliminó correctamente." }
      format.json { head :no_content }
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def coupon_params
      params.require(:coupon).permit(:promotion_code, :usage_limit, :promotion_id)
    end
end
