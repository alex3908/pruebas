# frozen_string_literal: true

class Api::V1::PhasesController < API::V1::BaseController
  # GET
  load_and_authorize_resource :project
  load_and_authorize_resource :phase, through: :project

  def index
    @phases = @phases.search(params).paginate(page: params[:page], per_page: @per_page)
  end
end
