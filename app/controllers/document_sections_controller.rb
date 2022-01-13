# frozen_string_literal: true

class DocumentSectionsController < ApplicationController
  load_and_authorize_resource

  def index
    @document_sections = @document_sections.order(:order).paginate(page: params[:page], per_page: @per_page)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    if @document_section.save
      redirect_to document_sections_path, success: "Sección de Documentos creado correctamente."
    else
      render :new
    end
  end

  def update
    if @document_section.update(document_section_params)
      redirect_to document_sections_path, success: "Sección de Documentos editado correctamente."
    else
      render :edit
    end
  end

  def destroy
    @document_section.destroy
    redirect_to document_sections_path, success: "Sección de Documentos eliminado correctamente."
  end

    private
      def document_section_params
        params.require(:document_section).permit(
          :name
        )
      end
end
