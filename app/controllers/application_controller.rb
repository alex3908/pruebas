# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Response, ErrorsHelper, SetCurrentUser, DateHelper

  impersonates :user

  protect_from_forgery with: :exception
  layout :layout_by_resource

  before_bugsnag_notify :add_user_info_to_bugsnag
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_branches, if: :devise_controller?, only: [:edit, :update]
  before_action :set_constants, :set_current_user
  before_action :load_announcements, unless: :devise_controller?
  before_action :verify_status_evo, except: [:pending]
  before_action :set_paper_trail_whodunnit

  helper_method :folder_filter_url

  add_flash_types :success, :warning, :danger, :info

  rescue_from ActiveRecord::ActiveRecordError, with: :render_500 if Rails.env.production?
  rescue_from ActionController::RoutingError, with: :render_404 if Rails.env.production?
  rescue_from ActionController::UnknownFormat, with: :render_404 if Rails.env.production?
  rescue_from ActiveRecord::RecordNotFound, with: :render_404 if Rails.env.production?

  protected
    def set_branches
      @branches = Branch.all
    end

    def add_user_info_to_bugsnag(report)
      report.user = {
          email: current_user.email,
          name: current_user.label,
          id: current_user.id
      }
    end

    def load_announcements
      @announcements = Announcement.for_user(Current.user).or(Announcement.global.now_showing.not_expired).order(created_at: :desc) unless Current.user.nil?
    end

    def authenticate_inviter!
      authenticate_admin!(force: true)
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:avatar])
      devise_parameter_sanitizer.permit(:account_update, keys: [:avatar, :first_name, :last_name])
    end

    # Catch all CanCan errors and alert the user of the exception
    rescue_from CanCan::AccessDenied do |exception|
      unless exception&.message == "You are not authorized to access this page."
        message = exception&.message
      end
      message ||= "No tiene permisos para acceder a esta secci\u00F3n"

      respond_to do |format|
        format.json { head :forbidden }
        format.js { render template: "errors/cancan", locals: { message: message } }
        format.all { redirect_to root_path, alert: message }
      end
    end

    def after_sign_in_path_for(user)
      if can?(:read, Project)
        projects_path
      else
        root_path
      end
    end

    def folder_filter_url
      "/folders"
    end

    def user_for_paper_trail
      Current.user
    end


  private

    def layout_by_resource
      devise_controller = controller_name == "passwords" || controller_name == "invitations" || action_name == "new"
      if devise_controller? && resource_name == :user && devise_controller
        "devise"
      else
        "application"
      end
    end

    def set_constants
      @per_page_default = 10
      @base_total_payments = 180
      @evo_roles = %w[director vice_director manager coordinator salesman realtor]

      settings = Setting.where(key: [ "evo_string",  "privacy-policy",
          "company-name", "full-company-name", "phone", "legal-company-name", "home-page"
      ])

      @evo_string = settings.find { |s| s.key == "evo_string" }&.convert
      @privacy_policy = settings.find { |s| s.key == "privacy-policy" }&.convert
      @phone = settings.find { |s| s.key == "phone" }&.convert
      @home_page = settings.find { |s| s.key == "home-page" }&.convert
      @full_company_name = @company_name = settings.find { |s| s.key == "company-name" }&.convert

      @project_singular = Settings.project_singular
      @project_plural = @project_singular&.pluralize(:es)

      @phase_singular = Settings.phase_singular
      @phase_plural = @phase_singular&.pluralize(:es)

      @stage_singular = Settings.stage_singular
      @stage_plural = @stage_singular&.pluralize(:es)

      @evo_active = Role.exists?(is_evo: true)
      @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
      @server_name = "El servidor"
    end

    def verify_status_evo
      if can?(:evo_access, User) && true_user == current_user
        status = current_user.structure.present? ? current_user.structure.active : true

        unless status
          redirect_to pending_status_path
        end
      end
    end

    def translate_month_by_date(month)
      months = {
          "January" => "Enero",
          "February" => "Febrero",
          "March" => "Marzo",
          "April" => "Abril",
          "May" => "Mayo",
          "June" => "Junio",
          "July" => "Julio",
          "August" => "Agosto",
          "September" => "Septiembre",
          "October" => "Octubre",
          "November" => "Noviembre",
          "December" => "Diciembre"
      }
      months[month]
    end

    def translate_date_by_string(date)
      date = date.split("/")
      month = date[1]
      months = {
          "01" => "Enero",
          "02" => "Febrero",
          "03" => "Marzo",
          "04" => "Abril",
          "05" => "Mayo",
          "06" => "Junio",
          "07" => "Julio",
          "08" => "Agosto",
          "09" => "Septiembre",
          "10" => "Octubre",
          "11" => "Noviembre",
          "12" => "Diciembre",
      }

      "#{date[0]} de #{months[month]} de #{date[2]}"
    end

    def render_pdf(name, file, orientation = "Portrait")
      render pdf: name,
             template: file,
             layout: "pdf.html",
             orientation: orientation,
             lowquality: true,
             zoom: 1,
             dpi: 75,
             page_size: "Letter",
             footer: @with_page_number ? { right: "[page] / [topage]", font_name: "Arial", font_size: 9 } : {},
             margin: @with_margins ? { top: "50px", bottom: "50px", left: "50px", right: "50px" } : { top: 0, bottom: 0, left: 0, right: 0 }
    end

    def render_pdf_from_string(file)
      WickedPdf.new.pdf_from_string file,
                                    layout: "pdf",
                                    lowquality: true,
                                    zoom: 1,
                                    dpi: 75,
                                    page_size: "Letter",
                                    footer: @with_page_number ? { right: "[page] / [topage]", font_name: "Arial", font_size: 9 } : {},
                                    margin: @with_margins ? { top: "50px", bottom: "50px", left: "50px", right: "50px" } : { top: 0, bottom: 0, left: 0, right: 0 }
    end

    def payment_gateway_url(path, environment)
      if environment == "test"
        URI.join("https://gateway-154.netpaydev.com", path).to_s
      else
        URI.join("https://suite.netpay.com.mx", path).to_s
      end
    end

    def payment_url(environment)
      if environment == "test"
        URI.join("https://wppsandbox.mit.com.mx/gen").to_s
      else
        URI.join("", path).to_s
      end
    end

    def to_boolean(string)
      ActiveModel::Type::Boolean.new.cast(string)
    end
end
