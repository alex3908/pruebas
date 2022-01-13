# frozen_string_literal: true

class EmailTemplatesController < ApplicationController
  load_and_authorize_resource

  def index
    @email_templates = EmailTemplate.all.paginate(page: params[:page], per_page: @per_page)
  end

  def new
  end

  def edit
  end

  def create
    respond_to do |format|
      if @email_template.save
        format.html { redirect_to email_templates_path, notice: "La plantilla fue creada correctamente." }
      else
        format.html { redirect_to email_templates_path, alert: @email_template.errors.values.join(",") }
      end
    end
  end

  def update
    respond_to do |format|
      if @email_template.update(email_template_params)
        format.html { redirect_to email_templates_path, notice: "La plantilla fue editada correctamente." }
      else
        format.html { redirect_to email_templates_path, alert: @email_template.errors.values.join(",") }
      end
    end
  end

  def destroy
    @email_template.destroy
    respond_to do |format|
      format.html { redirect_to email_templates_url, notice: "La plantilla fue eliminada correctamente." }
      format.json { head :no_content }
    end
  end

  def liquid_tags
    yaml_text = File.open("lib/liquid_tags.yml")
    hash = YAML.load(yaml_text)
    hash.shift
    @tags = HashWithIndifferentAccess.new(hash)
    render "tags/liquid_tags"
  end

  def see_preview_modal
    respond_to do |format|
      format.html
      format.js
    end
  end

  def send_preview_template
    emails = parse_emails(params[:emails])
    emails.each do |email|
      next if Devise.email_regexp.match?(email)
      @email_template.errors.add(:email, ": El correo #{email} no es un correo válido")
    end

    if @email_template.errors.empty?
      PreviewTemplateMailer.send_preview(@email_template, emails).deliver_later
    end
  rescue StandardError => ex
    @error = ex
    Bugsnag.notify(ex)
  end

  def remove_file
    email_template = EmailTemplate.find(params[:id])
    attachment = ActiveStorage::Attachment.find(params[:file_id])
    attachment.purge
    redirect_to edit_email_template_path(email_template), flash: { success: "Se elimino correctamente el archivo." }
  rescue Exception
    redirect_to edit_email_template_path(email_template), flash: { error: "No se pudo eliminar el archivo." }
  end

  private

    def email_template_params
      params.require(:email_template).permit(:title, :subject, :use_system_template, :html, attachments: [])
    end

    def parse_emails(emails)
      emails.split(",").map { |e| e.strip }
    end
end
