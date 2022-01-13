# frozen_string_literal: true

class DocumentTemplatesController < ApplicationController
  load_and_authorize_resource
  before_action :get_document_sections, only: [:index, :new, :edit]
  before_action :get_step_documents, :get_supported_formats, only: [:new, :edit]

  def index
    @q = DocumentTemplate.ransack(params[:q])
    @document_templates = @q.result.includes(:document_section).order(:order).paginate(page: params[:page], per_page: @per_page)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    if @document_template.save
      redirect_to edit_document_template_path(@document_template), success: "Documento creado correctamente."
    else
      render :new
    end
  end

  def update
    if @document_template.update(document_template_params)
      redirect_to document_templates_path, success: "Documento editado correctamente."
    else
      render :edit
    end
  end

  private
    def get_document_sections
      @document_section = DocumentSection.all
    end

    def get_step_documents
      @step_documents = @document_template.step_documents.joins(:step).order(:order)
    end

    def get_supported_formats
      @formats = DocumentTemplate::FILE_TYPES
    end

    def document_template_params
      params.require(:document_template)
            .permit(
              :name,
              :doc_type,
              :client_type,
              :document_section_id,
              :permissions,
              :key,
              :requires_approval,
              :copy_to_all,
              :visible,
              formats: [],
              step_documents_attributes: [
                :id,
                :required
              ]
            )
    end
end
