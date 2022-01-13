# frozen_string_literal: true

class AvailabilityController < ApplicationController
  include QuotationHandler, QuotationsHelper, DiscountsHelper, DownPaymentsHelper, EntityNamesConcern

  helper_method :encode_base_64
  skip_before_action :verify_authenticity_token, only: :send_quotation

  before_action :set_user, except: [:lot]
  before_action :set_lot_and_relatives, only: [:lot, :quote, :send_quotation]
  before_action :set_project_entity_names_by_project, only: [:send_quotation]
  before_action :file_to_load, only: [:send_quotation]
  before_action :set_quotation_wrapper, only: [:quote, :send_quotation, :lot]
  before_action :set_custom_data, only: [:lot, :quote]
  before_action :generate, only: [:lot, :quote, :send_quotation]
  before_action :set_layout_and_template, only: [:lots]

  # GET /disponibilidad
  def lots
    @google_tag = Setting.find_by(key: "availability_analitics_key")&.convert

    if params[:slug_project].present? && params[:slug_phase].present?
      @project = Project.find_by!(slug: params[:slug_project])
      @phase = Phase.find_by!(project: @project, slug: params[:slug_phase])
    elsif params[:fase].present?
      @phase = Phase.find_by!(id: decode_base_64(params[:fase].to_s))
    end

    if params[:slug_phase].present? && params[:slug_stage].present?
      @stage = Stage.find_by!(phase: @phase, slug: params[:slug_stage], active: true)
    elsif params[:etapa].present?
      @stage = Stage.find_by!(id: decode_base_64(params[:etapa].to_s), active: true)
    end

    if @stage.present?
      @project = @stage.phase.project
      if @stage.blueprint
        ActiveStorage::Downloader.new(@stage.blueprint.svg_file).download_blob_to_tempfile do |file|
          @map = Map.new(file.path)
          @extras = @map.read_extra_data
        end
      end

      @total_payments = @stage.credit_scheme.periods.inject(0) { |sum, period| sum + period.payments }

    elsif @phase.present?
      @project = @phase.project
      @stages = Stage.includes(phase: :project).search(params)
      if @phase.blueprint
        ActiveStorage::Downloader.new(@phase.blueprint.svg_file).download_blob_to_tempfile do |file|
          @map = Map.new(file.path)
          @extras = @map.read_extra_data
        end
      end
    else
      raise ActionController::RoutingError.new("Not Found")
    end

    respond_to do |format|
      format.svg { render partial: "blueprint" }
      format.html { render layout: @layout, template: @template }
    end
  end

  # GET /disponibilidad/:id.json
  def lot
    respond_to do |format|
      format.js { { lot: @lot, quotation: @quotation } }
    end
  end

  def quote
    respond_to do |format|
      format.json
      format.js
    end
  end

  def send_quotation
    @client = Client.find_by(email: params[:email])

    if @client.nil?
      @client = Client.create!(name: params[:name],
                              first_surname: params[:first_surname],
                              second_surname: params[:second_surname],
                              email: params[:email],
                              main_phone: params[:main_phone],
                              person: Client::PHYSICAL,
                              source: AutomatedEmail.sources[:public_quote])
      @client.client_users.create(user: @user, client_user_concept: Client.default_client_concept)
    end

    SendPublicQuotationJob.perform_later(@quotation.as_json,
                                          @pdf,
                                          current_user,
                                          @project,
                                          @stage,
                                          @lot,
                                          @client,
                                          @company_name,
                                          @stage_singular,
                                          @phase_singular,
                                          @project_singular)

    respond_to do |format|
      format.js
    end
  end

  def contact_information
    @stage = Stage.find_by!(id: decode_base_64(params[:etapa].to_s))
    @phase = @stage.phase
    @project = @phase.project

    emails = []
    emails << @project.email
    emails << @user.email if @user.present?

    @email_sent = QuotationMailer.send_contact_information(emails, @stage, @phase, params[:name], params[:first_surname], params[:main_phone], params[:message]).deliver_later

    respond_to do |format|
      format.js
    end
  end

  private

    def lot_params
      params.permit(:etapa, :vendedor, :name, :first_surname, :second_surname, :email, :main_phone)
    end

    def decode_base_64(element)
      Base64.decode64(element)
    end

    def encode_base_64(element)
      Base64.encode64(element.to_s)
    end

    def set_user
      if params[:vendedor].present?
        @user = User.find_by!(id: decode_base_64(params[:vendedor].to_s))
      end
    end

    def set_quotation_wrapper
      set_quotation(@user)
    end

    def set_layout_and_template
      if params[:iframe].present?
        @template = "availability/iframe"
        @layout = "iframe"
      elsif (params[:fase].present? && params[:etapa].nil?) || (params[:slug_phase].present? && params[:slug_stage].nil?)
        @template = "availability/phases"
        @layout = "availability"
      else
        @template = "availability/lots"
        @layout = "availability"
      end
    end
end
