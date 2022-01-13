# frozen_string_literal: true

class Api::V1::AttachmentsController < API::V1::BaseController
  def index
    @attachments = ActiveStorage::Attachment.includes(:blob).all
  end

  def show
    @attachment = ActiveStorage::Attachment.includes(:blob).find(params[:id])
  end
end
