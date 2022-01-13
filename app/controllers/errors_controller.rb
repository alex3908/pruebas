# frozen_string_literal: true

class ErrorsController < ApplicationController
  include ErrorsHelper

  def show
    render status_code.to_s, status: status_code
  end

  private

    def status_code
      params[:status_code]
    end
end
