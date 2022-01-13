# frozen_string_literal: true

class StructuresController < ApplicationController
  authorize_resource except: [:get_subordinates]
  include StructuresHelper
  require "securerandom"
  before_action :validate_access
  before_action :verify_initial_message, only: [:show]
  before_action :set_role, only: [:update_level, :replace_role, :change_role, :set_child_node, :see_structure_tree, :see_level_configurations_modal, :update_level_configurations]
  before_action :set_structure, only: [:information, :show, :approve, :reject, :set_child_node, :update_level, :update_level_configurations, :see_configuration, :update_configuration, :replace_role, :add_child_node, :change_role, :level_settings, :see_level_configurations_modal, :resend_invitation, :reset_password]
  before_action :verify_access, only: [:approve, :reject]
  before_action :has_node_access?, only: [:show]
  before_action :set_ancestry, only: [:unaffiliated_users, :affiliated_user, :new_user, :create_user]
  before_action :verify_max_branches, only: [:new_user, :unaffiliated_users, :create_user, :affiliated_user]
  before_action :set_referents, only: [:new_user]
  before_action :set_role_without_levels, only: [:add_child_node, :replace_role]
  helper_method :toggle_data, :get_translate, :get_status

  def show
    @max_level = Role.max_level

    @structure = current_user.structure if current_user&.has_structure? && @structure.nil?

    @role = set_current_role_level

    @structures = @structure.present? ? @structure.children : Structure.root_nodes

    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    @structures = @structures.includes(:role).order(created_at: :asc).paginate(page: params[:page], per_page: @per_page)

    @structure_label = subordinates_label(@structure)

    @return_path = (@structure.nil? || @structure == current_user&.structure) ? sales_path : subordinates_structures_path(@structure.parent_id)
  end

  def information
    @user = @structure.user

    @clients = Client.includes(:client_users).where(client_users: { user_id: @user.id }).order(created_at: :desc).paginate(page: params[:page], per_page: @per_page)

    if can?(:create, Project)
      @projects = Project.includes(phases: :stages)
    else
      stages = current_user.stages
      @projects = current_user.projects.includes(phases: :stages).where(phases: { stages: { active: true, id: stages } })
    end

    @return_path = (@structure.nil? || @structure == current_user&.structure) ? sales_path : subordinates_structures_path(@structure.parent_id)
    @logs = Log.where(element: "structure", element_id: @structure.id)
  end

  def fire
    @structure = Structure.find(params[:id])
    salesman_role = Role.find_by(key: "salesman")
    @fired_user = @structure.user.label
    @structure.user.update(is_active: false, role: salesman_role)

    if @structure.descendants.size.zero?
      @structure.destroy
    else
      @structure.update(user: nil)
    end

    respond_to do |format|
      format.html { redirect_to subordinates_structures_path(@structure.parent_id), flash: { success: "El usuario #{@fired_user} ha sido retirado de su puesto." } }
      format.js
    end
  end

  def hire
    hired_user = User.find(params[:user])
    @structure = Structure.find(params[:id])
    @structure.update(user: hired_user, active: false)
    hired_user.update(is_active: true, role: @structure.role)
    respond_to do |format|
      format.html { redirect_to subordinates_structures_path(@structure.parent_id), flash: { success: "Se ha asignado exitosamente a #{@structure.user.label}." } }
      format.js
    end
  end

  def prospects
    @users = User.without_structure.where.not(id: current_user.id)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def destroy
    @structure = Structure.find(params[:id])
    salesman_role = Role.find_by(key: "salesman")
    ActiveRecord::Base.transaction do
      @structure.user&.update!(is_active: false, role: salesman_role)
      descendants = @structure.descendants
      if descendants.size > 0
        descendants.each do |descendant|
          descendant.user&.update!(is_active: false, role: salesman_role)
          descendant.destroy
        end
      end
      @structure.destroy
    end

    respond_to do |format|
      format.html { redirect_to subordinates_structures_path(@structure.parent_id), flash: { success: "Nivel eliminado con éxito." } }
      format.js
    end
  end

  def get_subordinates
    user = User.find(params[:user_id])
    respond_to do |f|
      f.json { render json: user.subordinates, status: :ok }
    end
  end

  def approve
    if @access_error
      render :show, locals: { error: "not_access", action: "aprobar" }
    else
      if @structure.update!(active: true) && @user.update!(is_active: true)
        ApprovalsMailer.send_approved(@user).deliver_later
        render :show
      else
        render :show
      end
    end
  end

  def reject
    render :show, locals: { error: "not_access", action: "rechazar" } if @access_error
    if @structure.has_children?
      @structure.update!(active: false, user: nil)
    else
      @structure.destroy
    end
    salesman_role = Role.find_by(key: "salesman")
    @user.update!(is_active: false, role: salesman_role)
    render :show, locals: { type: "reject" }
  end

  def unaffiliated_users
    @structure_label = params[:structure_label]
    @users = User.without_structure.where.not(id: current_user.id)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def affiliated_user
    begin
      if @can_create_structures
        role = define_current_role(@ancestry)
        user = User.find_by(id: params[:user])
        settings = get_settings(role)

        ActiveRecord::Base.transaction do
          @structure = Structure.create!(
            role: role,
            user: user,
            parent: @ancestry,
            active: false,
            max_branches: settings[:max_branches]
          )

          user.update!(is_active: true, role: role)
        end
      end
    rescue StandardError => ex
      @error = ex
      Bugsnag.notify(ex)
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new_user
    @structure_label = params[:structure_label]
    @branches = Branch.all
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create_user
    if @can_create_structures
      role = define_current_role(@ancestry)
      ActiveRecord::Base.transaction do
        @user = User.new(user_params)
        @user.password = SecureRandom.hex(8)
        @user.created_by = current_user.id
        @user.role = role

        settings = get_settings(@user.role)

        @user.structure = Structure.new(
          role: @user.role,
          parent: @ancestry,
          active: false,
          max_branches: settings[:max_branches]
        )

        if @user.save
          @user.invite!(current_user)
          return if params.dig(:user, :referent, :referrer).nil?

          referent_commission = Setting.find_by(key: "referent_commission").try(:convert)

          referent_params = {
            referrer_id: params.dig(:user, :referent, :referrer),
            invited_id: @user.id,
            commission: referent_commission
          }

          Referent.create(referent_params)
        end
      end
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def replace_role
    respond_to do |format|
      format.html
      format.js
    end
  end

  def add_child_node
    respond_to do |format|
      format.html
      format.js
    end
  end

  def set_child_node
    last_level = Role.last_of_the_structure
    next_level = last_level.present? ? last_level.next_level : 0
    @role.update!(level: next_level, is_evo: true)
  rescue StandardError => ex
    @error = ex
    Bugsnag.notify(ex)
  end

  def change_role
    role = Role.find_by(id: params[:role])
    ActiveRecord::Base.transaction do
      role.update!(level: @role.level, is_evo: true)
      @role.update!(level: nil, is_evo: false)
    end
  rescue StandardError => ex
    @error = ex
    Bugsnag.notify(ex)
  end

  def see_level_configurations_modal
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update_level_configurations
    ActiveRecord::Base.transaction do
      @role.update!(role_params)
      if params[:role][:update_all].to_i == 1
        @role.structures.update_all(get_settings(@role))
      end
    end
  rescue StandardError => ex
    @error = ex
    Bugsnag.notify(ex)
  end

  def see_configuration
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update_configuration
    @structure.update!(structure_params)
  rescue StandardError => ex
    @error = ex
    Bugsnag.notify(ex)
  end

  def see_structure_tree
    @levels = Role.evo_structure
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update_level
    begin
      childrens = @role.childrens
      ActiveRecord::Base.transaction do
        @role.update!(is_evo: false, level: nil, commission_monitoring: 0, sale_commission: 0, maximum_schemes: 0)
        childrens.update_all(is_evo: false, level: nil, commission_monitoring: 0, sale_commission: 0, maximum_schemes: 0)
      end
    rescue StandardError => ex
      @error = ex
      Bugsnag.notify(ex)
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def level_settings
    @levels = Role.evo_structure
  end

  def resend_invitation
    begin
      user = @structure.user
      user.invitation_accepted_at = nil

      if user.save
        user.invite!(current_user)
      end
    rescue StandardError => ex
      @error = ex
      Bugsnag.notify(ex)
    end

    respond_to do |format|
      format.js
    end
  end

  def reset_password
    begin
      user = @structure.user
      user.send_reset_password_instructions
    rescue StandardError => ex
      @error = ex
      Bugsnag.notify(ex)
    end

    respond_to do |format|
      format.js
    end
  end


  private

    def set_structure
      @structure = Structure.find_by(id: params[:id])
    end

    def get_translate(key)
      attributes = {
          "role_id" => "Nivel",
          "user_id" => "Responsable",
          "ancestry" => "Líder",
          "sale_commission" => "Comisión por venta",
          "commission" => "Comisión por seguimiento",
          "active" => "Estado",
          "max_branches" => "Subordinados permitidos",
      }
      attributes[key]
    end

    def get_status(status)
      status ? "Activo" : "Pendiente"
    end

    def verify_access
      @user = @structure.user
      @access_error = false
      if current_user&.role&.is_evo
        @access_error = true unless users_to_approve.include?(@user.id)
      else
        users_structure_not_active = User.left_joins(:structure).where(structures: { id: nil }).or(User.left_joins(:structure).where(structures: { active: false }))
        @access_error = true unless users_structure_not_active.include?(@user)
      end
    end

    def has_node_access?
      return if !current_user&.has_structure?
      return if current_user&.has_structure? && @structure.nil?
      return if current_user&.has_structure? && current_user&.structure == @structure
      return if current_user&.has_structure? && current_user&.structure.ancestor_of?(@structure)

      redirect_to root_path, flash: { error: "No puedes acceder al nivel deseado, unicamente puedes tener acceso a los niveles que te pertenecen." }
    end

    def set_ancestry
      @ancestry = Structure.find_by(id: params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :phone, :email, :branch_id, :referent)
    end

    def get_settings(role)
      {
        commission: role.commission_monitoring,
        sale_commission: role.sale_commission,
        max_branches: role.maximum_schemes
      }
    end

    def verify_max_branches
      @can_create_structures = @ancestry.present? ? (@ancestry.direct_subordinates_active.size < (@ancestry.max_branches || 0)) : true
    end

    def set_referents
      @referents = User.all
    end

    def verify_initial_message
      @show_initial_message = Role.where.not(level: nil).empty?
    end

    def set_role
      @role = Role.find_by(id: params[:role_id])
    end

    def set_current_role_level
      define_current_role(@structure)
    end

    def set_role_without_levels
      @roles = Role.where(level: nil)
    end

    def define_current_role(structure)
      return structure.role.next if structure.present?
      Role.root
    end

    def subordinates_label(structure)
      if Role.root.nil?
        nil
      elsif structure.nil?
        Role.root&.name.pluralize(:es)
      elsif structure.role.next.present?
        structure.role.next.name.pluralize(:es)
      else
        "Subordinados"
      end
    end

    def role_params
      params
      .require(:role)
      .permit(
        :maximum_schemes
      )
    end

    def structure_params
      params
      .require(:structure)
      .permit(
        :max_branches
      )
    end

    def toggle_data(url)
      {
        activate: "toggle", onstyle: "success", offstyle: "secondary", on: params[:stage] ? "Asignado" : "Visible", off: params[:stage] ? "Asignado" : "No Visible", size: "sm",
        remote: true, url: url, method: :patch
      }
    end

    def validate_access
      raise CanCan::AccessDenied.new("No tienes permisos para acceder a la vista de estructuras") unless can?(:read, Structure) && (current_user&.has_structure? || !current_user&.has_structure? && cannot?(:reserve, :quote))
    end
end
