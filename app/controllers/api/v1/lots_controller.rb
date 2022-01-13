# frozen_string_literal: true

class Api::V1::LotsController < API::V1::BaseController
  load_and_authorize_resource :project
  load_and_authorize_resource :phase, through: :project
  load_and_authorize_resource :stage, through: :phase
  load_and_authorize_resource :lot, through: :stage

  before_action :set_disposition, only: [:blueprint, :annexe, :map_annexe]

  # GET
  def index
    @lots = @lots.search(params).paginate(page: params[:page], per_page: @per_page)
  end

  def show
  end

  def blueprint
    send_data @stage.blueprint_document(@lot).render_to_string(layout: false), filename: "blueprint.svg", type: "image/svg+xml", disposition: @disposition
  end

  def annexe
    annexe = Annexe_2.new(@lot)
    send_data annexe.to_pdf, filename: "annexe.pdf", type: "application/pdf", disposition: @disposition
  end

  def map_annexe
    annexe = Annexe_3.new(@lot)
    send_data annexe.to_pdf, filename: "annexe.pdf", type: "application/pdf", disposition: @disposition
  end

  private

    def set_disposition
      @disposition = params[:disposition].presence === "attachment" ? "attachment" : "inline"
    end
end
