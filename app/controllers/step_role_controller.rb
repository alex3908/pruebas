# frozen_string_literal: true

class StepRoleController < ApplicationController
  def allow
    step_role_id = params[:step_role_id]
    document = params[:document_id]

    @toggle_document = DownloadableFile.where(step_role_id: step_role_id, document: document)
    if @toggle_document.present? && @toggle_document.delete_all
      render json: {}, status: :no_content
    elsif DownloadableFile.create(step_role_id: step_role_id, document: document)
      render json: {}, status: :created
    else
      render json: {}, status: :unprocessable_entity
    end
  end
end
