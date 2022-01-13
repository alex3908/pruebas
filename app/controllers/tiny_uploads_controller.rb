# frozen_string_literal: true

class TinyUploadsController < ApplicationController
  skip_forgery_protection
  def create
    tiny_upload = TinyUpload.create(email_template_params)
    render json: { location: url_for(tiny_upload.file) }, content_type:  "text / html"
  rescue
    render :not_acceptable
  end
  def email_template_params
    params.permit(:file)
  end
end
