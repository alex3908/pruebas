# frozen_string_literal: true

class FileApproval < ApplicationRecord
  TYPE = { DOCUMENT: "document", USER: "user" }
  STATUS = { UNCHECKED: 0, REJECTED: 1, APPROVED: 2 }
  enum status: [:unchecked, :rejected, :approved]

  belongs_to :approvable, polymorphic: true
  belongs_to :approved_by, class_name: "User", foreign_key: "approved_by_id", optional: true

  before_save :add_user_who_approves

  scope :of_documents, -> (_params) { joins("INNER JOIN documents ON documents.id = file_approvals.approvable_id").search(TYPE[:DOCUMENT], _params) }
  scope :of_users, -> (_params) { joins("INNER JOIN users ON users.id = file_approvals.approvable_id").search(TYPE[:USER], _params) }

  def self.set_order(params, sort_column, sort_direction)
    order(sort_column + " " + sort_direction).paginate(page: params[:page], per_page: params[:per_page])
  end

  def self.search(type, params)
    file_approvals = all

    if type == TYPE[:USER]
      file_approvals = file_approvals.where(approvable_type: "User")
      file_approvals = file_approvals.where(status: params[:status]) if params[:status].present?
      file_approvals = file_approvals.where("users.branch_id" => params[:branch]) if params[:branch].present?
      file_approvals = file_approvals.where("LOWER(CONCAT(first_name, last_name)) LIKE LOWER(?)", "%#{params[:name]}%".delete(" \t\r\n")) if params[:name].present?
      file_approvals = file_approvals.where("LOWER(email) LIKE LOWER(?)", "%#{params[:email]}%".delete(" \t\r\n")) if params[:email].present?
    elsif type == TYPE[:DOCUMENT]
      file_approvals = file_approvals.where(approvable_type: "Document")
      file_approvals = file_approvals.joins("
        INNER JOIN folders ON documentable_type = 'Folder' and documents.documentable_id = folders.id
        INNER JOIN users ON users.id = folders.user_id
        INNER JOIN lots ON lots.id = folders.lot_id
        INNER JOIN stages ON stages.id = lots.stage_id
        INNER JOIN phases ON phases.id = stages.phase_id
        INNER JOIN projects ON projects.id = phases.project_id")
      file_approvals = file_approvals.where(status: params[:status]) if params[:status].present?
      file_approvals = file_approvals.where("projects.id" => params[:project]) if params[:project].present?
      file_approvals = file_approvals.where("phases.id" => params[:phase]) if params[:phase].present?
      file_approvals = file_approvals.where("stages.id" => params[:stage]) if params[:stage].present?
      file_approvals = file_approvals.where("lots.number" => params[:lot_number].delete(" \t\r\n")) if params[:lot_number].present?
      file_approvals = file_approvals.where("LOWER(lots.label) = LOWER(?)", params[:lot_label].delete(" \t\r\n")) if params[:lot_label].present?
      file_approvals = file_approvals.where("LOWER(branches.name) LIKE LOWER(?)", "%#{params[:branch]}%".delete(" \t\r\n")) if params[:branch].present?
    else
      raise Exception.new "Unknown type"
    end
    file_approvals
  end

  def approve
    self.update(status: STATUS[:APPROVED])
  end

  def reject(params)
    self.update(status: STATUS[:REJECTED], comment: params[:comment])
  end

  def edit
    self.update(status: STATUS[:UNCHECKED])
  end

  def file
    self.approvable.public_send(self.key)
  end

  private
    def add_user_who_approves
      if changes[:status].present? && changes[:status].last.in?(["approved", "rejected"])
        self.approved_by = Current.user
        self.approved_at = Time.zone.now
      end
    end
end
