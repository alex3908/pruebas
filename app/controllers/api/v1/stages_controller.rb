# frozen_string_literal: true

class Api::V1::StagesController < API::V1::BaseController
  # GET
  load_and_authorize_resource :project
  load_and_authorize_resource :phase, through: :project
  load_and_authorize_resource :stage, through: :phase

  before_action :set_disposition, only: [:blueprint, :annexe, :map_annexe]

  def index
    if can?(:reserve, :quote)
      @stage_users = StageUser.where(user: current_user)
      @stages = @stages.where(stage_users: @stage_users, active: true).includes(:lots).order(order: :asc)
    else
      @stages = @stages.includes(:lots).where(active: true).order(order: :asc)
    end
    @stages = @stages.search(params).paginate(page: params[:page], per_page: @per_page)
  end

  def show
  end

  def blueprint
    send_data @phase.blueprint_document(@stage).render_to_string(layout: false), filename: "blueprint.svg", type: "image/svg+xml", disposition: @disposition
  end

  def annexe
    annexe = Annexe_1.new(@stage)
    send_data annexe.to_pdf, filename: "annexe.pdf", type: "application/pdf", disposition: "inline"
  end

  private

    def set_disposition
      @disposition = params[:disposition].presence === "attachment" ? "attachment" : "inline"
    end
end
