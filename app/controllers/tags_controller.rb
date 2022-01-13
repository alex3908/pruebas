# frozen_string_literal: true

class TagsController < ApplicationController
  load_and_authorize_resource except: [:activate]

  def index
    @tags = @tags.order(created_at: :asc).paginate(page: params[:page], per_page: @per_page)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    if @tag.save
      redirect_to tags_path, success: "Pregunta creada correctamente."
    else
      render :new
    end
  end

  def update
    if @tag.update(tag_params)
      redirect_to tags_path, success: "Pregunta editada correctamente."
    else
      render :edit
    end
  end

  def destroy
    @tag.destroy
    redirect_to tags_path, success: "Pregunta eliminada correctamente."
  end

  def activate
    raise CanCan::AccessDenied.new("No tienes permisos para activar esta etiqueta") unless can?(:update, Tag)
    @tag.toggle!(:active)
  end

    private

      def tag_params
        params.require(:tag).permit(:name, :key, :related_to, :active)
      end
end
