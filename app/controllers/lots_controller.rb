# frozen_string_literal: true

class LotsController < ApplicationController
  include FoldersHelper, ContractsHelper, EntityNamesConcern
  load_and_authorize_resource :project
  load_and_authorize_resource :phase, through: :project
  load_and_authorize_resource :stage, through: :phase
  load_and_authorize_resource :lot, through: :stage
  before_action :set_project_entity_names_by_project
  before_action :set_tags, only: [:new, :edit]
  skip_before_action :verify_authenticity_token, only: [:annexes]

  # GET /lots
  def index
    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    @lots = @stage.lots.order(created_at: :asc).paginate(page: params[:page], per_page: @per_page)
    if @stage.blueprint
      ActiveStorage::Downloader.new(@stage.blueprint.svg_file).download_blob_to_tempfile do |file|
        @map = Map.new(file.path)
        @extras = @map.read_extra_data
      end
    end
  end

  # GET /lots/1
  def show
  end

  # GET /lots/new
  def new
    @lot = Lot.new
    @lot.build_address
  end

  # POST /lots
  def create
    @lot.stage = @stage
    if @lot.save
      redirect_to project_phase_stage_lots_path(@project, @phase, @stage), success: "#{@lot_singular} creado correctamente."
    else
      render :new
    end
  end

  # GET /lots/1/edit
  def edit
    @lot.build_address unless @lot.address
  end

  # PATCH/PUT /lots/1
  def update
    if @lot.update(lot_params)
      redirect_to project_phase_stage_lots_path(@project, @phase, @stage, page: params[:page]), success: "#{@lot_singular} editado correctamente."
    else
      render :edit
    end
  end

  def deallocate
    @blueprint_lot = @lot.blueprint_lot
    @lot.blueprint_lot = nil
    respond_to do |format|
      if @blueprint_lot.present? && @lot.save
        format.html { redirect_to project_phase_stage_lots_path(@project, @phase, @stage, page: params[:page], per_page: params[:per_page]), notice: "El #{@lot_singular} se ha desasignado correctamente." }
        format.js
        format.json { render json: @lot, status: :ok, location: @lot }
      else
        format.html { redirect_to project_phase_stage_lots_path(@project, @phase, @stage, page: params[:page], per_page: params[:per_page]), notice: "Hubo un error al intentar hacer el cambio." }
        format.js
        format.json { render json: @lot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE
  def destroy
    respond_to do |format|
      if @lot.for_sale? || @lot.locked_sale?
        @lot.destroy
        format.html { redirect_to project_phase_stage_lots_path(@project, @phase, @stage, page: params[:page], per_page: params[:per_page]), notice: "#{@lot_singular} eliminado correctamente." }
        format.json { head :no_content }
      else
        format.html { redirect_to project_phase_stage_lots_path(@project, @phase, @stage, page: params[:page], per_page: params[:per_page]), notice: "No es posible eliminar ese #{@lot_singular}." }
        format.json { status :unprocessable_entity }
      end
    end
  end

  def change_status
    if @lot.update(lot_params)
      json_response(@lot, :ok, @include)
    else
      json_response(@lot.errors, :unprocessable_entity)
    end
  end

  def lock
    if @lot.for_sale?
      @lot.status = Lot::STATUS[:LOCKED_SALE]
    elsif @lot.locked_sale?
      @lot.status = Lot::STATUS[:FOR_SALE]
    end

    respond_to do |format|
      if !@lot.status_changed?
        format.html { redirect_to project_phase_stage_lots_path(@project, @phase, @stage), notice: "No es posible realizar esta accion para un #{@lot_singular} #{ @lot.sold? ? "Vendido" : "Reservado"}" }
        format.js
        format.json { render json: @lot, status: :not_modified, location: @lot }
      elsif @lot.save!
        format.html { redirect_to project_phase_stage_lots_path(@project, @phase, @stage), notice: "El #{@lot_singular} se ha #{@lot.for_sale? ? "puesto a la venta" : "bloqueado"} correctamente." }
        format.js
        format.json { render json: @lot, status: :ok, location: @lot }
      else
        format.html redirect_to project_phase_stage_lots_path(@project, @phase, @stage), notice: "Hubo un error al intentar hacer el cambio."
        format.js
        format.json { render json: @lot.errors, status: :unprocessable_entity }
      end
    end
  end

  def annexes
    job_status = JobStatus.create!(name: "Anexos #{@lot_singular} #{@lot.reference} - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = LotAnnexeJob.perform_later(job_status.id, @lot.id)
    job_status.update(job_id: job.provider_job_id)


    respond_to do |format|
      format.json { render job_status }
    end
  end

  def annexe_1
    annexe = Annexe_1.new(@lot.stage, { controller: self })

    respond_to do |format|
      format.pdf { send_data annexe.to_pdf, filename: "annexe_1.pdf", type: "application/pdf", disposition: "inline" }
      format.html { render html: annexe.render_to_string } unless Rails.env.production?
    end
  end

  def annexe_2
    annexe = Annexe_2.new(@lot, { controller: self })

    respond_to do |format|
      format.pdf { send_data annexe.to_pdf, filename: "annexe_2.pdf", type: "application/pdf", disposition: "inline" }
      format.html { render html: annexe.render_to_string } unless Rails.env.production?
    end
  end

  def annexe_3
    annexe = Annexe_3.new(@lot, { controller: self })

    respond_to do |format|
      format.pdf { send_data annexe.to_pdf, filename: "annexe_3.pdf", type: "application/pdf", disposition: "inline" }
      format.html { render html: annexe.render_to_string } unless Rails.env.production?
    end
  end

  def remove_file
    attachment = ActiveStorage::Attachment.find(params[:key])
    attachment.purge_later
    redirect_to edit_project_phase_stage_lot_path(@project, @phase, @stage, @lot), flash: { success: "Se eliminó correctamente el archivo." }
  end

  def export
    lots_ids = @stage.lots.order(created_at: :asc).pluck(:id)
    job_status = JobStatus.create!(name: "#{@lot_plural} - #{Time.zone.now.strftime("%m/%d/%Y %I:%M%p ")}", user: current_user, status: "pending")
    job = LotExportJob.perform_later(job_status,   lots_ids)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def import
    job_status = JobStatus.create!(
      name: "Actualización de #{@lot_plural} - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}",
      user: current_user,
      status: "pending",
      action: :up_and_downloadable,
      file: params[:file]
    )

    job = LotImportJob.perform_later(job_status, @stage)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  private
    def lot_params
      params.require(:lot).permit(:rid, :label, :depth, :front, :price, :stage, :status, :area, :south, :north,
                                  :east, :west, :adjoining_south, :adjoining_north, :adjoining_east, :adjoining_west,
                                  :chepina, :map, :scripture, :permission, :description, :planking, :folio, :number, :undivided,
                                  :fixed_price, :color, :colloquial_name, :identification_name, :owner_name,
                                  :acquisition_cost, :market_price, :exchange_rate, :vocation, :descriptive_status, :northeast, :southeast,
                                  :northwest, :southwest, :adjoining_northeast, :adjoining_southeast, :adjoining_northwest, :adjoining_southwest,
                                  address_attributes: address_params,
                                  pdf_annexes: [])
    end

    def set_tags
      @tags = Tag.where(active: true, related_to: ["lots", "all"]).order(id: :ASC)
    end

    def address_params
      [
        :id,
        :country,
        :postal_code,
        :state,
        :city,
        :colony,
        :street,
        :location,
        :house_number,
        :interior_number,
        :_destroy
      ]
    end
end
