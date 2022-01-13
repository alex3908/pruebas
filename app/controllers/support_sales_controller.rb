# frozen_string_literal: true

include ActionView::Helpers::DateHelper

class SupportSalesController < ApplicationController
  load_resource :folder, only: [:show], id_param: :id
  load_resource only: [:create, :update]
  before_action :set_folder, except: [:show]

  def create
    @support_sale.folder = @folder

    if can?(:request_support, Folder)
      @support_sale.save
    else
      redirect_to root_path, flash: { error: "No tienes permiso para realizar esta acción" }
    end

    respond_to do |format|
      format.html { render inline: render_to_string(:create, layout: false) }
    end
  end

  def show
    @support_sale = @folder.support_sales.active.take

    if @support_sale.nil?
      redirect_to(folder_path(@folder), flash: { error: "Este expediente no cuenta con una solicitud de soporte activa." }) && (return)
    end

    unless current_user_involved
      redirect_to root_url, flash: { error: "No tienes permisos para acceder a este sitio" }
    end

    @view = case current_user
            when @support_sale.request_manager
              "request_manager"
            when @support_sale.requester
              "requester"
            when @support_sale.support_manager
              "support_manager"
            when @support_sale.support_coordinator
              "support_coordinator"
    end

    support_manager = @support_sale.support_manager
    support_coordinator = @support_sale.support_coordinator
    supporter = @support_sale.supporter

    if (@support_sale.support_review? || @support_sale.approved?) && support_manager.present?
      @support_managers = [support_manager]
    elsif @view == "request_manager"
      @support_managers = User.where(role: Role.find_by_key("manager")).with_parent(@support_sale.support_vicedirector.structure) - [current_user]
    end

    if support_coordinator.present?
      @support_coordinators = [support_coordinator]
    elsif support_manager.present? && support_manager.structure.present?
      @support_coordinators = User.where(role: Role.find_by_key("coordinator")).with_parent(support_manager.structure)
    end

    if supporter.present?
      @supporters = [supporter]
    elsif support_coordinator.present? && support_coordinator.structure.present?
      @supporters = User.where(role: Role.find_by_key("salesman")).with_parent(support_coordinator.structure) + [current_user]
    end
  end

  def update
    if @support_sale.update(support_sale_params)
      flash[:success] = "La solicitud fue actualizada correctamente."
      redirect_to(support_sale_folder_path(@support_sale.folder))
      return
    else
      flash[:error] = "La solicitud no pudo ser guardada."
    end

    render :show
  end

  private
    def current_user_involved
      @support_sale.user_involved?(current_user)
    end

    def support_sale_params
      params.require(:support_sale).permit(:status, :requester_id, :support_vicedirector_id, :support_manager_id, :support_coordinator_id, :supporter_id)
    end

    def set_folder
      @folder = Folder.find(params[:folder_id])
    end
end
