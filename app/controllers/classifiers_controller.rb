# frozen_string_literal: true

class ClassifiersController < ApplicationController
  load_and_authorize_resource

  def index
    @classifiers = @classifiers.order(created_at: :asc).paginate(page: params[:page], per_page: @per_page)
  end

  def create
    if @classifier.save
      redirect_to classifiers_path, success: "Clasificador creado correctamente."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @classifier.update(classifier_params)
      redirect_to classifiers_path, success: "Clasificador actualizado correctamente."
    else
      render :edit
    end
  end

  private

    def classifier_params
      params.require(:classifier).permit(:name, role_ids: [])
    end
end
