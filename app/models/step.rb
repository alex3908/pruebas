# frozen_string_literal: true

class Step < ApplicationRecord
  include RailsSortable::Model
  acts_as_paranoid
  default_scope { order(:order) }
  set_sortable :order

  has_many :folders
  has_many :step_roles, dependent: :destroy
  has_many :roles, through: :step_roles
  has_many :step_logs
  has_many :step_documents, dependent: :destroy
  has_many :evaluation_steps
  has_many :evaluations, through: :evaluation_steps
  has_many :referrer_steps, class_name: "Step", foreign_key: "reject_step_id"
  has_many :digital_signature_services
  has_many :step_document_templates, dependent: :destroy
  has_many :document_templates, through: :step_document_templates, dependent: :delete_all
  belongs_to :reject_step, class_name: "Step", foreign_key: "reject_step_id", required: false
  belongs_to :folder_user_concept, optional: true
  belongs_to :client_user_concept, optional: true

  accepts_nested_attributes_for :step_roles, reject_if: proc { |attributes| attributes[:role_id].blank? && attributes[:id].blank? }, allow_destroy: true

  after_create :create_documents_templates_requirements

  alias_method :reject_step_item, :reject_step

  def self.first_step
    Step.find_by(order: Step.minimum(:order))
  end

  def self.last_step
    Step.find_by(order: Step.maximum(:order))
  end

  def is_first_one?
    self == Step.first_step
  end

  def is_last_one?
    self == Step.last_step
  end

  def next_step
    Step.where("steps.order > (?)", self.order).first
  end

  def prev_step
    Step.where("steps.order < (?)", self.order).last
  end

  def reject_step
    reject_step_item || Step.first_step
  end

  def create_documents_templates_requirements
    DocumentTemplate.find_each do |template|
      StepDocument.create(step: self, document_template: template)
    end
  end

  def filtered_folders(params)
    if params["from_step_log_date"].present? && params["to_step_log_date"].present?
      filter_by_step_log_date_range(params, eager_load: [:step, :user, step_logs: :step, lot: :stage, documents: [:file_versions, document_template: [step_documents: :step]]])
    else
      filtered = folders_selection
        .includes(:step, documents: [:file_versions, document_template: [step_documents: :step]], folder_users: [user: :role])
        .left_joins(:installments)
        .set_params(params)
        .group(:id)

      filtered
    end
  end

  def pipeline_amount(params)
    if params["from_step_log_date"].present? && params["to_step_log_date"].present?
      filtered = filter_by_step_log_date_range(params)
    else
      filtered = folders_selection.left_joins(:installments).set_params(params).group(:id)
    end

    filtered.inject(0) { |sum, folder| sum + (folder.total_sale || 0) }
  end

  def count_folders(params)
    if params["from_step_log_date"].present? && params["to_step_log_date"].present?
      filtered = filter_by_step_log_date_range(params)

      filtered.to_a.count
    else
      folders_selection.set_params(params).count
    end
  end

  private
    def filter_by_step_log_date_range(params, eager_load: [])
      folders = Folder.find_by_sql(["
                                 SELECT * FROM folders WHERE id IN (
                                  SELECT DISTINCT (filtered_folders.id) FROM (
                                   SELECT DISTINCT(folders.*), step_logs.moved_at FROM folders
                                   LEFT JOIN step_logs ON step_logs.folder_id = folders.id
                                   LEFT JOIN steps ON step_logs.step_id = steps.id
                                   WHERE (DATE(step_logs.moved_at AT TIME ZONE 'GMT-5') BETWEEN :from_date AND :to_date AND step_logs.step_id = :step_id
                                     AND (SELECT step_logs.step_id FROM step_logs
                                     WHERE step_logs.folder_id = folders.id
                                     ORDER BY step_logs.moved_at DESC LIMIT(1)) = :step_id
                                   )
                                   GROUP BY folders.id, step_logs.moved_at
                                   ORDER BY step_logs.moved_at DESC
                                  ) AS filtered_folders
                                )",
                                    { step_order: self.order, step_id: self.id, from_date: Date.parse(params[:from_step_log_date]), to_date: Date.parse(params[:to_step_log_date]) }
                                  ])

      folders = folders_selection.where(id: folders.map(&:id))
      folders = folders.includes(eager_load) if eager_load.any?

      folders
       .left_joins(:installments)
       .set_params(params.except("step"))
       .group(:id)
    end

    def show_previous
    end

    def folders_selection
      (Current.user.structure.present? || Current.user.can?(:reserve, :quote)) && Current.user.cannot?(:see_all_branches, Folder) ? Current.user.folders.where(step: self) : self.folders
    end
end
