# frozen_string_literal: true

module FolderHandler
  extend ActiveSupport::Concern

  def folder_report_filter(current_user, params)
    if cannot?(:see_all_branches, Folder)
      params[:branch] = current_user.branch_id
    end
    get_folders(params: params).as_json(only: :id).map { |element| element["id"] }
  end

  def sort_column
    if Folder.column_names.include?(params[:sort]) || ["project_id", "phase_id", "stage_id", "folio", "folder_created"].include?(params[:sort])
      return "users.first_name" if params[:sort] == "user_id"
      return "clients.name" if params[:sort] == "client_id"
      return "lots.name" if params[:sort] == "lot_id"
      return "projects.name" if params[:sort] == "project_id"
      return "phases.name" if params[:sort] == "phase_id"
      return "stages.name" if params[:sort] == "stage_id"
      return "folders.id" if params[:sort] == "folio"
      return "folders.created_at" if params[:sort] == "folder_created"
      params[:sort]
    else
      "folders.created_at"
    end
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end


  def send_folder_email(prev_step, next_step, folder)
    return unless folder.active_mails

    if prev_step.present?
      automated_exit_emails = AutomatedEmail.where(step: prev_step, execution_type: AutomatedEmail.executions[:exit_step])
      automated_exit_emails.each do |exit_email|
        AutomatedEmailMailer.send_automated_email(folder, exit_email).deliver_later
      end
    end

    if next_step.present?
      automated_enter_emails = AutomatedEmail.where(step: next_step, execution_type: AutomatedEmail.executions[:enter_step])
      automated_enter_emails.each do |enter_email|
        AutomatedEmailMailer.send_automated_email(folder, enter_email).deliver_later
      end
    end
  end
end
