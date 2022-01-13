# frozen_string_literal: true

class StatusController < ApplicationController
  # GET /availability
  def pending
    status = current_user&.structure.present? ? current_user.structure.active : true

    unless status
      render layout: "status"
    else
      redirect_to root_path
    end
  end
end
