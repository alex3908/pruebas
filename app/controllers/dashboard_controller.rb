# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :set_section

  def index
  end

  private

    def set_section
      @section = "dashboard"
    end
end
