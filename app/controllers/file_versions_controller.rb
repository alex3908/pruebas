# frozen_string_literal: true

class FileVersionsController < ApplicationController
  before_action :set_file_version

  def destroy
    @file_version.destroy
    redirect_to @file_version.document, success: "Se eliminó correctamente el archivo."
  end

  private
    def set_file_version
      @file_version = FileVersion.find(params[:id])
    end
end
