# frozen_string_literal: true

class Api::V1::PromotionsController < API::V1::BaseController
  load_and_authorize_resource :project
  load_and_authorize_resource :phase, through: :project
  load_and_authorize_resource :stage, through: :phase
  load_and_authorize_resource :promotion, through: :stage

  def index
    @promotions = @promotions.active
  end
end
