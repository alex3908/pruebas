# frozen_string_literal: true

class IdentificationTypesController < ApplicationController
  load_and_authorize_resource

  # GET /identification_types
  # GET /identification_types.json
  def index
    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    @identification_types = @identification_types.order(created_at: :asc).paginate(page: params[:page], per_page: @per_page)
  end

  # GET /identification_types/1
  # GET /identification_types/1.json
  def show
  end

  # GET /identification_types/new
  def new
  end

  # GET /identification_types/1/edit
  def edit
  end

  # POST /identification_types
  # POST /identification_types.json
  def create
    respond_to do |format|
      if @identification_type.save
        format.html { redirect_to @identification_type, notice: "El tipo de identificacion oficial fue creado exitosamente." }
        format.json { render :show, status: :created, location: @identification_type }
      else
        format.html { render :new }
        format.json { render json: @identification_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /identification_types/1
  # PATCH/PUT /identification_types/1.json
  def update
    respond_to do |format|
      if @identification_type.update(identification_type_params)
        format.html { redirect_to @identification_type, notice: "El tipo de identificacion oficial fue actualizado exitosamente." }
        format.json { render :show, status: :ok, location: @identification_type }
      else
        format.html { render :edit }
        format.json { render json: @identification_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /identification_types/1
  # DELETE /identification_types/1.json
  def destroy
    @identification_type.destroy
    respond_to do |format|
      format.html { redirect_to identification_types_url, notice: "El tipo de identificacion oficial fue eliminado exitosamente." }
      format.json { head :no_content }
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def identification_type_params
      params.require(:identification_type).permit(:name, :institution, :display_as)
    end
end
