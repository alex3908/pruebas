# frozen_string_literal: true

class LeadSourcesController < ApplicationController
  load_and_authorize_resource

  def index
    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    @lead_sources = @lead_sources.order(created_at: :asc).paginate(page: params[:page], per_page: @per_page)
  end


  # GET /lead_sources/new
  def new; end

  # POST /lead_sources
  def create
    if @lead_source.save
      redirect_to lead_sources_path, success: "Origen creado correctamente."
    else
      render :new
    end
  end

  # GET /lead_sources/edit
  def edit; end

  # PATCH/PUT /lead_sources/1
  def update
    if @lead_source.update(lead_source_params)
      redirect_to lead_sources_path, success: "Origen actualizado correctamente."
    else
      render :edit
    end
  end

  # DELETE /lead_sources/1
  def destroy
    @lead_source.destroy
    redirect_to lead_sources_path, success: "Origen eliminado correctamente."
  end

  # PATCH /lead_sources/:lead_source_id/activate
  def activate
    @lead_source.toggle!(:active)
  end

  private

    def lead_source_params
      params.require(:lead_source).permit(:name, :source_key)
    end
end
