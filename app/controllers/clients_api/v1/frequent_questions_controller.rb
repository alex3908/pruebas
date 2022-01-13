# frozen_string_literal: true

class ClientsApi::V1::FrequentQuestionsController < ClientsAPI::V1::BaseController
  def index
    frequent_questions = FrequentQuestion.where(status: "released").paginate(page: params[:page], per_page: @per_page)
    render json: frequent_questions
  end
end
