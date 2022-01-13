# frozen_string_literal: true

class StagesController < ApplicationController
  include QuotationsHelper, DiscountsHelper, StagesHelper, EntityNamesConcern, TagsHelper
  load_and_authorize_resource :project
  load_and_authorize_resource :phase, through: :project
  load_and_authorize_resource :stage, through: :phase
  before_action :set_project_entity_names_by_project
  before_action :set_enterprises, only: [:new, :edit]
  before_action :set_tags, only: [:new, :create, :edit, :update]
  before_action :verify_access, except: [:new, :create]
  helper_method :encode_base_64, :translate_stage_type

  STAGES = [
    commercial: "Comercial",
    residential: "Residencial",
  ]

  # GET /stages
  def index
    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default

    if can?(:create, Stage)
      @stages = @stages.includes(:lots).order(order: :asc)
    else
      @stage_users = StageUser.where(user: current_user)
      @stages = @stages.where(stage_users: @stage_users, active: true).includes(:lots).order(order: :asc)
      @phase = Phase.includes(blueprint: { blueprint_stages: :stage }).find_by(id: @phase.id)
    end

    if @phase.blueprint
      ActiveStorage::Downloader.new(@phase.blueprint.svg_file).download_blob_to_tempfile do |file|
        @map = Map.new(file.path)
        @extras = @map.read_extra_data
      end
    end

    @stages_residential = @stages.where(stage_type: "residential")
    @stages_commercial = @stages.where(stage_type: "commercial")
  end

  # GET /stages/1
  def show
    return redirect_to root_url, flash: { error: "No tiene permisos para generar una cotización en esta #{@stage_singular.downcase}" } if can?(:reserve, :quote) && (!current_user.stages.include?(@stage) || !@stage.active?)
    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    @clients = Client.accessible_by(current_ability).includes(:user).order(created_at: :desc).paginate(page: params[:page], per_page: @per_page)
    @stage = Stage.includes(blueprint: [ blueprint_lots: :lot, svg_file_attachment: :blob ]).find_by(id: @stage.id)

    if @stage.blueprint
      ActiveStorage::Downloader.new(@stage.blueprint.svg_file).download_blob_to_tempfile do |file|
        @map = Map.new(file.path)
        @extras = @map.read_extra_data
      end
    else
      @lots = @stage.lots.paginate(page: params[:page], per_page: @per_page)
    end

    render :show
  end

  # GET /stages/new
  def new
    @blueprint = Blueprint.new
  end

  # GET /stages/1/edit
  def edit
    @blueprint = @stage.blueprint
  end

  # POST /stages
  def create
    @stage = @phase.stages.build(stage_params)
    @stage.active = false
    if @stage.save
      redirect_to project_phase_stages_path(@project, @phase), success: "#{@stage_singular} creada correctamente."
    else
      @stage.slug = nil if @stage.errors.added?(:slug, :taken, value: @stage.slug)
      render :new
    end
  end

  # PATCH/PUT /stages/1
  def update
    ActiveRecord::Base.transaction do
      if blueprint_present?
        if params[:stage][:blueprint][:file].present?
          add_blueprint
        else
          edit_blueprint
        end
      end

      params[:stage][:start_installments] = nil if params[:down_payment_differ].nil?

      @stage.update!(stage_params)
    end
    redirect_to project_phase_stages_path(@project, @phase), success: "#{@stage_singular} actualizada correctamente."
  rescue ActiveRecord::RecordInvalid
    @stage.slug = nil if @stage.errors.added?(:slug, :taken, value: @stage.slug)
    render :edit
  end

  # DELETE /stages/1
  def destroy
    @stage.destroy
    redirect_to project_path(@project), success: "#{@stage_singular} eliminada correctamente."
  end


  def initial_charge
  end

  def status
    if @stage.is_residential?
      @previous_stage = Stage.find_by(order: @stage.order - 1, phase: @phase.id)

      if @previous_stage.present?
        @blueprint = Blueprint.find_by(level: Blueprint::LEVEL[:STAGE], level_id: @previous_stage.id)

        if can?(:force_activate, Stage)
          if @blueprint.present?
            @stage.toggle!(:active)
            message = @stage.active ? "La #{@stage_singular} ha sido activada." : "La #{@stage_singular} ha sido desactivada."
            status = "success"
          else
            @stage.toggle!(:active)
            message = @stage.active ? "La #{@stage_singular} ha sido activada. Asigne un plano a esta #{@stage_singular}." : "La #{@stage_singular} ha sido desactivada."
            status = "success"
          end
        else
          if @previous_stage.active
            sold_lots_percentage = @previous_stage.lots.length.zero? ? 0 : @previous_stage.sold_lots * 100 / @previous_stage.lots.length
            if sold_lots_percentage >= 90
              if @blueprint.present?
                @stage.toggle!(:active)
                @stage.active ? message = "La #{@stage_singular} ha sido activada." : message = "La #{@stage_singular} ha sido desactivada."
                status = "success"
              else
                message = "No se ha asignado un plano a esta #{@stage_singular}."
                status = "error"
              end
            else
              message = "No se ha cubierto el 90% de las ventas en la #{@stage_singular} anterior."
              status = "error"
            end
          elsif !@previous_stage.active
            message = "Las #{@stage_plural} sólo pueden ser liberadas en orden."
            status = "error"
          end
        end
      else
        @stage.toggle!(:active)
        message = @stage.active ? "La #{@stage_singular} ha sido activada." : "La #{@stage_singular} ha sido desactivada."
        status = "success"
      end
    else
      @stage.toggle!(:active)
      message = @stage.active ? "La #{@stage_singular} ha sido activada." : "La #{@stage_singular} ha sido desactivada."
      status = "success"
    end

    render json: { message: message, status: status }
  end

  def deallocate
    @blueprint_stage = @stage.blueprint_stage
    @stage.blueprint_stage = nil
    respond_to do |format|
      if @blueprint_stage.present? && @stage.save!
        format.html { redirect_to project_phase_stages_path(@project, @phase, page: params[:page], per_page: params[:per_page]), notice: "La privada se ha desasignado correctamente." }
        format.js
        format.json { render json: @stage, status: :ok, location: @stage }
      else
        format.html { redirect_to project_phase_stage_path(@project, @phase, page: params[:page], per_page: params[:per_page]), notice: "Hubo un error al intentar hacer el cambio." }
        format.js
        format.json { render json: @stage.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove_file
    attachment = ActiveStorage::Attachment.find(params[:key])
    attachment.purge_later
    redirect_to edit_project_phase_stage_path(@project, @phase, @stage), flash: { success: "Se eliminó correctamente el archivo." }
  end

  def show_stage_commission_schemes_roles
    @commission_scheme_id = params[:commission_scheme_id]
    @stage = Stage.find_or_initialize_by(id: params[:stage_id])
    @folder_user_concepts = FolderUserConcept.all

    render partial: "stage_commission_schemes_roles", locals: { stage_commission_schemes_roles: get_stage_commission_schemes_roles(@stage.id, @commission_scheme_id) }
  end

  private

    def blueprint_params
      params.require(:stage).require(:blueprint).permit(:reserved_color, :sold_color, :available_color, :locked_color)
    end

    def stage_params
      params.require(:stage).permit(:name, :enterprise_id, :phase_id, :release_date, :start_date,
                                    :stage_type, :initial_payment_expiration,
                                    :down_payment_expiration, :reference, :lock_seller_period,
                                    :payment_expiration, :delivery_date, :price,
                                    :payment_email, :credit_scheme_id, :annex,
                                    :lot_description, :active_annexes,
                                    :show_full_name, :start_date_by, :emails, :opening_commission,
                                    :active_commissions, :max_commission_amount,
                                    :sudden_death, :purchase_conditions,
                                    :observations, :receipt_observations, :active_messages, :is_expirable, :active_mails,
                                    :lot_description_title, :stage_description_title, :phase_description_title,
                                    :slug, :owner_enterprise_id, :commission_scheme_id, pdf_annexes: [],
                                    stages_commission_schemes_roles_attributes: stages_commission_schemes_roles_params
                                   )
    end

    def stages_commission_schemes_roles_params
      [ :id, :commission_schemes_role_id, :folder_user_concept_id, :_destroy, users: [] ]
    end

    def add_blueprint
      @map = Map.new(retrieve_svg_file.path)

      @blueprint = Blueprint.create(blueprint_params.merge({ level_id: @stage.id, level_type: @stage.class.name }))

      @blueprint.svg_file.purge
      @blueprint.svg_file.attach(retrieve_svg_file)
      @blueprint.background.purge
      @blueprint.background.attach(retrieve_background)
      if @blueprint.invalid?
        raise ActiveRecord::RecordInvalid, @blueprint
      end
      @blueprint.styles = @map.get_styles
      @blueprint.view_box = @map.read_view_box
      @blueprint.style = @map.read_style
      @stage.blueprint = @blueprint

      @blueprint_lots = @map.read_reference_data(BlueprintLot)

      @blueprint.blueprint_lots = @blueprint_lots
    end

    def edit_blueprint
      @blueprint = Blueprint.where(level_type: "Stage", level_id: @stage.id)
      @blueprint.update(blueprint_params)
    end

    def retrieve_svg_file
      params[:stage][:blueprint][:file]
    end

    def retrieve_background
      params[:stage][:blueprint][:background]
    end

    def encode_base_64(element)
      Base64.encode64(element.to_s)
    end

    def translate_stage_type(stage_type)
      StagesController::STAGES[stage_type.to_sym]
    end

    def set_enterprises
      @enterprises = Enterprise.all
    end

    def set_tags
      @tags = Tag.where(active: true, related_to: ["lots", "all"]).order(id: :ASC)
    end

    def blueprint_present?
      params[:stage].present? && params[:stage][:blueprint].present?
    end

    def verify_access
      if @stage.present?
        if can?(:create, Stage)
          stages = Stage.all.includes(:lots).order(order: :asc)
        else
          stage_users = StageUser.where(user: current_user)
          stages = Stage.where(stage_users: stage_users, active: true).includes(:lots).order(order: :asc)
        end

        raise CanCan::AccessDenied unless stages.pluck(:id).include?(@stage.id)
      end
    end

    def get_stage_commission_schemes_roles(stage_id, commission_scheme_id)
      stage_commission_schemes_roles = { commission_scheme_selected: [] }

      stage_commission_schemes_roles[:commission_scheme_not_selected] = StagesCommissionSchemesRole.includes(commission_schemes_role: [:role]).where(stage_id: stage_id).where.not(commission_schemes_roles: { commission_scheme_id: commission_scheme_id }).to_a

      stages_commission_schemes_roles = StagesCommissionSchemesRole.includes(commission_schemes_role: [:role]).where(stage_id: stage_id, commission_schemes_roles: { commission_scheme_id: commission_scheme_id }).to_a

      CommissionSchemesRole.includes(:role).where(commission_scheme_id: commission_scheme_id, roles: { is_evo: false }).each_with_index do |commission_schemes_role, idx|
        stage_commission_role = stages_commission_schemes_roles.detect { |item| item.commission_schemes_role_id == commission_schemes_role.id }
        if stage_commission_role.present?
          stage_commission_schemes_roles[:commission_scheme_selected] << stage_commission_role
        else
          stage_commission_schemes_roles[:commission_scheme_selected] << StagesCommissionSchemesRole.new(stage_id: stage_id, commission_schemes_role_id: commission_schemes_role.id)
        end
      end

      stage_commission_schemes_roles
    end
end
