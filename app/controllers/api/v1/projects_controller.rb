# frozen_string_literal: true

class Api::V1::ProjectsController < API::V1::BaseController
  load_and_authorize_resource :project
  # GET
  def index
    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    if can?(:reserve, :quote)
      @project_users = ProjectUser.where(user_id: current_user.id)
      @projects = @projects.where(project_users: @project_users).order(order: :asc).includes(phases: :stages)
    else
      @projects = @projects.order(order: :asc).includes(phases: :stages)
    end
    @projects = @projects.search(params).paginate(page: params[:page], per_page: @per_page)
  end
end
