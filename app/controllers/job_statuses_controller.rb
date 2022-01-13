# frozen_string_literal: true

class JobStatusesController < ApplicationController
  load_and_authorize_resource
  helper_method :sort_column, :sort_direction


  # GET /job_statuses
  # GET /job_statuses.json
  def index
    @job_statuses = @job_statuses.includes(file_attachment: :blob).not_expired.where(user: current_user).order(sort_column + " " + sort_direction).paginate(page: params[:page], per_page: @per_page)
  end

  def read_logs
    @job_class = params[:job_class]
    if @job_class == "price_leveler"
      @job_statuses = PriceLevelerJobStatus.all
    else
      @job_statuses = @job_statuses.where(job_class: @job_class)
    end
  end

  # GET /job_statuses/1
  # GET /job_statuses/1.json
  def show
  end

  # GET /job_statuses/1/cancel
  def cancel
    @job_status.cancel!

    if params[:logs] == "price_leveler"
      redirect_to read_logs_job_statuses_path(job_class: :price_leveler)
    end
  end

  private
    def sort_column
      if JobStatus.column_names.include?(params[:sort])
        params[:sort]
      else
        "created_at"
      end
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end
end
