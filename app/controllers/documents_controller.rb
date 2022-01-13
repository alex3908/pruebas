# frozen_string_literal: true

class DocumentsController < ApplicationController
  before_action :set_folder, :set_document

  def show
  end

  def approve
    raise CanCan::AccessDenied unless can?(:verify, DocumentTemplate)
    approval = @document.file_approval
    approval.approve

    redirect_to folder_path(@folder), success: "Se aprobó correctamente el archivo."
  end

  def reject
    raise CanCan::AccessDenied unless can?(:verify, DocumentTemplate)
    approval = @document.file_approval
    approval.reject(params)

    respond_to do |format|
      format.js
    end
  end

  private
    def set_folder
      @folder = Folder.find(params[:folder_id]) if params[:folder_id].present?
    end

    def set_document
      @document = Document.find(params[:id])
    end
end
