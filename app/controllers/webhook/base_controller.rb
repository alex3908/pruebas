# frozen_string_literal: true

# Base class API controller

class Webhook::BaseController < ActionController::API
  include Response
  include ExceptionHandler
  include QuotationsHelper

  # called before every action on controllers
  before_action :authorize_request, :set_constants
  attr_reader :current_user, :code_bad_request

  def initialize
  end

  def wicked_blob_path(image)
    return unless image.respond_to?(:blob)
    save_path = Rails.root.join("tmp", "#{image.id}")
    File.open(save_path, "wb") do |file|
      file << image.blob.download
    end
    save_path.to_s
  end

  def set_constants
    settings = Setting.where(key: [
        "project_singular", "phase_singular", "stage_singular"
    ])

    @project_singular = settings.find { |setting| setting.key == "project_singular" }.convert
    @phase_singular = settings.find { |setting| setting.key == "phase_singular" }.convert
    @stage_singular = settings.find { |setting| setting.key == "stage_singular" }.convert
  end

  private

    # Check for valid request token and return user
    def authorize_request
    end
end
