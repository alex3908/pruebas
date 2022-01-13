# frozen_string_literal: true

class UsersController < ApplicationController
  include UsersHelper
  require "securerandom"
  load_and_authorize_resource
  before_action :set_elements
  before_action :verify_max_branches, only: [:new, :create]
  before_action :set_referents, only: [:new, :create, :edit]
  before_action :set_roles, only: [:index, :new, :create, :edit, :update, :recovery]
  before_action :user_selection, only: [:index, :autocomplete, :assign_all, :deallocate_all]
  helper_method :toggle_data, :sort_column, :sort_direction, :get_translate, :get_status
  skip_before_action :verify_authenticity_token

  # GET /users
  def index
    respond_to do |format|
      format.xlsx {
        render :report

        response.headers[
            "Content-Disposition"
        ] = "attachment; filename=Reporte_de_Usuarios.xlsx"
      }
      format.html {
        @users = @users.paginate(page: params[:page], per_page: @per_page)
        render :index
      }
    end
  end

  def autocomplete
    if params[:user_search]
      query = params[:user_search]

      if params[:client_user_concept_id]

        client_user_concept = ClientUserConcept.find_by_id(params[:client_user_concept_id])
        users = User.where(role_id: client_user_concept.roles.pluck(:id))
      else
        users = User
      end
    elsif can?(:reassign_seller, Folder)
      @sellers = current_user.structure.present? ? User.where(id: current_user.structure.subtree.pluck(:user_id)).active : User.active.order(created_at: :desc)
      users = @sellers
      query = params[:search]
    end

    respond_to do |format|
      format.json {
        render json: users.autocomplete(query)
      }
    end
  end

  # GET /users/1
  def show
    @branches = Branch.all.order(id: :ASC)
    client_users = ClientUser.where(user_id: @user.id)

    if can?(:see_all, Client)
      client_ids = client_users.pluck(:client_id)
    elsif current_user.structure.present?
      client_ids = client_users.where(user_id: current_user.structure.subtree.pluck(:user_id)).pluck(:client_id)
    else
      client_ids = client_users.where(user_id: current_user.id).pluck(:client_id)
    end

    @clients = Client.where(id: client_ids).order(created_at: :desc).paginate(page: params[:page], per_page: @per_page)
    @logs = Log.where(element: "user", element_id: @user.id) if can?(:see_binnacle, User)

    if can?(:create, Project)
      @projects = Project.includes(phases: :stages)
    else
      stages = current_user.stages
      @projects = current_user.projects.includes(phases: :stages).where(phases: { stages: { active: true, id: stages } })
    end

    verify_action_ability(@user) if @evo_roles.include? current_user.role.key
  end

  # GET /users/new
  def new
  end

  # GET /users/1/edit
  def edit
    @referent = @user.referrer?
    @structure = @user.structure
    @leader = @user.structure.parent_id if @user.structure && @user.structure.parent.user_id.present?

    verify_action_ability(@user) if @evo_roles.include? current_user.role.key
  end

  # POST /users
  def create
    @user.password = SecureRandom.hex(8)
    @user.created_by = current_user.id

    # TODO: Move static to a Setting
    if @evo_roles.include?(@user.role.key) && params.dig(:user, :level, :leader).nil? && @user.role.key != "salesman"
      flash[:error] = "Debes seleccionar un responsable."
      render :new
    elsif @user.save
      manage_referent(@user)
      manage_structure(@user) if @evo_roles.include? @user.role.key
      @user.invite!(current_user)
      redirect_to @user, success: "Usuario creado."
    else
      render :new, flash: { error: "Ya existe un usuario con ese correo electrónico" }
    end
  end

  # PATCH/PUT /users/1
  def update
    @user = User.find(params[:user_id])
    email_changed = params.dig(:user, :password).present? && params.dig(:user, :password) != @user.email

    if params.dig(:user, :password) == ""
      params[:user].delete :password
    else
      if @user.invitation_accepted_at.nil?
        @user.invitation_token = nil
        @user.invitation_created_at = nil
        @user.invitation_sent_at = nil
      end
    end

    if @user.update(user_params)
      manage_referent(@user)
      manage_structure(@user) if @evo_roles.include? @user.role.key

      if email_changed
        if @user.invitation_sent_at.present? && @user.invitation_accepted_at.nil?
          @user.invite!(current_user)
          redirect_to @user, success: "Se ha enviado un correo de invitación a #{@user.email}"
        else
          @user.send_reset_password_instructions
          redirect_to @user, success: "Se ha enviado un correo de recuperación de contraseña a #{@user.email}"
        end
      else
        redirect_to @user, success: "El usuario se modificó correctamente."
      end
    else
      if @user.errors[:email].present?
        render :edit, flash: { error: "Ya existe un usuario con ese correo electrónico" }
      else
        render :edit, flash: { error: "Hubo un problema al editar el usuario" }
      end
    end
  end

  def reset_password
    user = User.find(params[:user_id])
    if user.send_reset_password_instructions
      redirect_to user, success: "Se ha enviado el correo de recuperación de contraseña."
    else
      redirect_to user, error: "Hubo un error al enviar el correo de recuperación de contraseña."
    end
  end

  # DELETE /users/:user_id
  def destroy
    @user.destroy
    redirect_to users_url, success: "Usuario eliminado correctamente."
  end

  # DELETE /users/1/suppression
  def delete_suppression
    @user.delete_suppression if @user.suppresed_email?
    redirect_to user_path(@user), success: "Email actualizado correctamente"
  end

  def assign_all
    job_status = JobStatus.create!(name: "Asignacion masiva (#{@users.count}) - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = ReassignStageUsersJob.perform_later(job_status, @users.pluck(:id), @stage.id, "assign")

    if job_status.update(job_id: job.provider_job_id)
      flash[:success] = "La asignación se ha programado con éxito."
    else
      flash[:error] = "Ocurrió un error al programar la nivelación."
    end

    redirect_to users_path(stage: @stage.id, email: params[:email], name: params[:name], role: params[:role], branch: params[:branch])
  end

  def deallocate_all
    job_status = JobStatus.create!(name: "Desasignacion masiva (#{@users.count}) - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = ReassignStageUsersJob.perform_later(job_status, @users.pluck(:id), @stage.id, "deallocate")

    if job_status.update(job_id: job.provider_job_id)
      flash[:success] = "La desasignación se ha programado con éxito."
    else
      flash[:error] = "Ocurrió un error al programar la nivelación."
    end

    redirect_to users_path(stage: @stage.id, email: params[:email], name: params[:name], role: params[:role], branch: params[:branch])
  end

  # GET /users/:user_id/edit
  def resend_invitation
    user = User.find(params[:user_id])
    user.invitation_accepted_at = nil

    if user.save
      user.invite!(current_user)
      redirect_to user, success: "Se ha reenviado correctamente la invitación."
    end
  end

  # PATCH /users/:user_id/activate_user
  def activate_user
    user = User.find(params[:user_id])
    redirect_to users_url, flash: { error: "El usuario cuenta con una estructura de ventas asignada." } if user.structure.present?
    user.toggle!(:is_active)
  end

  def assignment
    @user = User.find(params[:user_id])
    @assign = set_model("project").where(user_id: params[:user_id], project_id: params[:project_id])

    if @assign.size > 0
      @assign.delete_all
      render json: {}, status: :no_content
    else
      @project_user = set_model("project").new
      @project_user.user_id = params[:user_id]
      @project_user.project_id = params[:project_id]

      if @project_user.save
        json_response(@project_user, :created, @include)
      else
        json_response(@project_user.errors, :unprocessable_entity)
      end
    end
  end

  def assignment_stage
    @user = User.find(params[:user_id])
    @assign = set_model("stage").where(user_id: params[:user_id], stage_id: params[:stage_id])

    if @assign.size > 0
      @assign.delete_all
      render json: {}, status: :no_content
    else
      @stage_user = set_model("stage").new
      @stage_user.user_id = params[:user_id]
      @stage_user.stage_id = params[:stage_id]

      if @stage_user.save
        json_response(@stage_user, :created, @include)
      else
        json_response(@stage_user.errors, :unprocessable_entity)
      end
    end
  end

  def toggle_data(url)
    {
        activate: "toggle", onstyle: "success", offstyle: "secondary", on: params[:stage] ? "Asignado" : "Visible", off: params[:stage] ? "Asignado" : "No Visible", size: "sm",
        remote: true, url: url, method: :patch
    }
  end

  def become
    raise CanCan::AccessDenied unless true_user.can?(:become, User)
    impersonate_user User.find(params[:id])
    redirect_to root_url, success: "Has iniciado sesión en la cuenta de #{current_user.label}"
  end

  def exit
    raise CanCan::AccessDenied unless true_user.can?(:become, User)
    stop_impersonating_user
    redirect_to root_url, success: "Regresaste a tu usuario correctamente."
  end

  def get_leaders
    role = Role.find_by(id: params[:level])
    leader = role.leader
    superior = leader&.id

    if current_user.structure.present?
      @leaders = Structure.joins(:user, :role).where(users: { is_active: true, id: current_user.structure.subtree.pluck(:user_id) }, roles: { id: superior })
    else
      @leaders = Structure.joins(:user, :role).where(users: { is_active: true }, roles: { id: superior })
    end

    @leaders = @leaders.map { |structure| { id: structure.id, label: structure.user.label, email: structure.user.email } }
    respond_to do |f|
      f.json { render json: { levels: @leaders, leader: leader&.name }, status: :ok }
    end
  end

  def recovery
    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    @filter_path = recovery_users_path
    evo_users = User.includes(:role).where(roles: { is_evo: true })
    users_without_structure = evo_users.select { |user| user.structure.nil? }
    users = User.where(id: users_without_structure).includes(:branch, :role).set_params(params, sort_column, sort_direction)
    @users = users.paginate(page: params[:page], per_page: @per_page)
  end

  def remove_file
    attachment = ActiveStorage::Attachment.find_by(name: params[:key], record_type: User.to_s, record_id: current_user.id)
    approval = current_user.file_approvals.find_by(key: attachment.name)
    attachment.purge
    approval.destroy if approval.present?
    redirect_to edit_user_registration_path, success: "Se eliminó correctamente el archivo."
  end

  def validate_user
    @user = User.find(params[:id])
  end

  def approve_file
    raise CanCan::AccessDenied unless can?(:verify_user_file, User)
    @user = User.find(params[:user_id])
    approval = @user.file_approvals.where(key: params[:key]).first_or_initialize
    approval.approve

    redirect_to validate_user_path(@user), success: "Se aprobó correctamente el archivo."
  end

  def reject_file
    raise CanCan::AccessDenied unless can?(:verify_user_file, User)
    @user = User.find(params[:user_id])
    approval = @user.file_approvals.where(key: params[:key]).first_or_initialize
    approval.reject(params)

    respond_to do |format|
      format.js
    end
  end

  def rejectable_user_file
    respond_to do |format|
      format.html
      format.js
    end
  end

  def submit_documentation
    if current_user.update(user_params)
      redirect_to edit_user_registration_path, success: "Usuario editado correctamente."
    end
  end

  def delete_bank_account
    bank_account = current_user.bank_accounts.find_by(id: params[:account_id])
    bank_account.destroy if bank_account.present?

    redirect_to edit_user_registration_path, success: "Cuenta eliminada correctamente."
  end

  def referrals
    @users = User.joins(:invited, :role).where(referents: { referrer_id: current_user.id })
                 .paginate(page: params[:page], per_page: @per_page)
                 .set_params(params, sort_column, sort_direction)
  end

  def folders
    @projects = Project.includes(phases: :stages).order(id: :asc)
    @branches = Branch.all.order(id: :asc)
    @steps = Step.all
    @folders = Folder.search(params)
                     .where(user_id: params[:id])
                     .paginate(page: params[:page], per_page: @per_page)
  end

  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :phone, :email, :role_id, :password, :branch_id, :search_email,
                                  :search_first_name, :search_role, :is_active, :created_by, :referent, :written_curp, :written_rfc, :birthdate,
                                  :holder, :bank, :account_number, :currency, :clabe, :official_identification, :curp, :address_proof, :birth_certificate,
                                   :non_criminal_record, :job_reference, :recommendation_letter_1, :recommendation_letter_2, :rfc, :gender,  structure_attributes: [ :id, :digital ], classifier_ids: [])
    end

    def set_roles
      @roles = Role.permitted(can?(:view_hidden, Role)).order(id: :ASC)
    end

    def level_params
      params.require(:user).require(:level).permit(:leader)
    end

    def verify_max_branches
      @max_branches_reached = current_user.structure.present? && current_user.structure.direct_subordinates_active.size >= (current_user.structure.max_branches || 0)
    end

    def manage_structure(user)
      if current_user.role.is_evo
        leader_structure = user.structure.present? ? user.structure.parent.id : current_user.structure.id
      else
        return unless params.dig(:user, :level).present? || user.role.key == "director"
        leader_structure = params.dig(:user, :level, :leader)
      end

      user.structure.present? ? edit_structure(user, leader_structure) : create_structure(user, leader_structure)
    end

    def create_structure(user, superior)
      max_branches = user.role.maximum_schemes

      structure = Structure.new
      structure.user = user
      structure.role = user.role
      structure.parent = superior.present? ? Structure.find(superior) : nil
      structure.max_branches = max_branches
      structure.save
    end

    def edit_structure(user, superior)
      user.structure.update_attribute(:parent, Structure.find_by(id: superior))
    end

    def manage_referent(user)
      @referent_commission = Setting.find_by(key: "referent_commission").try(:convert)

      if user.referrer?
        if user.referrer?&.referrer_id.to_i != params.dig(:user, :referent, :referrer).to_i
          user.referrer?.destroy
          return unless params.dig(:user, :referent, :referrer).present?

          @referent = Referent.new
          @referent.referrer_id = params.dig(:user, :referent, :referrer)
          @referent.invited_id = user.id

          @referent.save
        end
      else
        return unless params.dig(:user, :referent, :referrer).present?
        @referent = Referent.new
        @referent.referrer_id = params.dig(:user, :referent, :referrer)
        @referent.invited_id = user.id
        @referent.save
      end
    end

    def set_elements
      @branches = Branch.all
    end

    def set_model(type)
      type == "project" ? ProjectUser : StageUser
    end

    def sort_column
      if User.column_names.include?(params[:sort]) || ["branch_id", "role_id"].include?(params[:sort])
        return "branches.name" if params[:sort] == "branch_id"
        return "roles.name" if params[:sort] == "role_id"
        params[:sort]
      else
        "first_name"
      end
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def verify_action_ability(user)
      evo_users = User.includes(:role).where(roles: { is_evo: true })
      users_without_structure = evo_users.select { |account| account.structure.nil? }
      users = User.where(id: current_user.structure.descendants.pluck(:user_id) | users_without_structure)
      raise CanCan::AccessDenied unless users.include? user
    end

    def get_translate(key)
      attributes = {
          "email" => "Correo Electrónico",
          "first_name" => "Nombre",
          "last_name" => "Apellido",
          "phone" => "Teléfono",
          "branch_id" => "Sucursal",
          "is_active" => "Estado",
          "birthdate" => "Fecha de Cumpleaños",
          "written_rfc" => "RFC",
          "written_curp" => "CURP",
          "user_id" => "Usuario",
          "ancestry" => "Líder",
          "sale_commission" => "Comisión por venta",
          "commission" => "Comisión por seguimiento",
          "active" => "Estado",
          "max_branches" => "Subordinados permitidos",
          "role_id" => "Rol",
          "structure" => "Superior",
      }
      attributes[key]
    end

    def get_status(status)
      status ? "Activo" : "Inactivo"
    end

    def set_referents
      @referents = User.all
    end

    def user_selection
      @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default

      if params[:stage].present?
        @stage = Stage.find(params[:stage])
        @phase = Phase.find(@stage.phase_id)
        @project = Project.find(@phase.project_id)
        @users = User.active.includes(:branch, :role).where(role: Role.find_by_key("salesman")).set_params(params, sort_column, sort_direction) if can?(:see_sellers, User)
        @users = User.active.includes(:branch).set_params(params, sort_column, sort_direction) unless can?(:see_sellers, User)
      else
        if can?(:see_sellers, User)
          @users = User.can_reserve.active.includes([:structure, :branch])
        elsif current_user&.structure.present?
          @users = User.where(id: current_user.structure.descendants.pluck(:user_id)).includes([:structure, :branch])
        else
          @users = User.all.includes([:structure, :branch])
        end
        @users = @users.includes(:branch, :role).set_params(params, sort_column, sort_direction)
      end

      @filter_path = params[:stage].present? ? users_path(stage: @stage.id) : users_path
    end
end
