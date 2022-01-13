# frozen_string_literal: true

class Stage < ApplicationRecord
  acts_as_paranoid
  include RailsSortable::Model
  include Filterable
  include PurchaseConditionsConcern

  STAGE_TYPES = %i[commercial residential]
  START_DATE_BY = { PHASE_DATE: "phase_date", STAGE_DATE: "stage_date" }

  enum start_date_by: { phase_date: "phase_date", stage_date: "stage_date" }

  set_sortable :order

  has_one :blueprint, as: :level, dependent: :destroy
  has_one :blueprint_stage

  has_many :lots, dependent: :destroy
  has_many :discounts, dependent: :destroy
  has_many :folders, through: :lots
  has_many :stage_users, dependent: :destroy
  has_many :sellers, through: :stage_users, source: :user
  has_many :stage_promotions, dependent: :destroy
  has_many :promotions, through: :stage_promotions
  has_many :stage_contracts, dependent: :destroy
  has_many :contracts, through: :stage_contracts
  has_many :stage_additional_concepts, dependent: :destroy
  has_many :additional_concepts, through: :stage_additional_concepts
  has_many :stages_commission_schemes_roles, dependent: :destroy

  accepts_nested_attributes_for :stages_commission_schemes_roles, reject_if: :all_blank, allow_destroy: true

  has_many_attached :pdf_annexes

  belongs_to :enterprise, class_name: "Enterprise", foreign_key: "enterprise_id"
  belongs_to :owner_enterprise, class_name: "Enterprise", foreign_key: "owner_enterprise_id", required: false
  belongs_to :phase
  belongs_to :credit_scheme
  belongs_to :commission_scheme

  has_paper_trail skip: [:updated_at], on: [:update]

  attr_accessor :emails

  validates :slug, uniqueness: { scope: :phase }
  validates :enterprise_id, presence: true, numericality: { only_integer: true }
  validate :pdf_annexes_file_type

  before_validation :parse_receptor_emails, :parameterize_slug

  before_create :set_order

  scope :same_as_user, ->(user) { joins(:sellers).where("users.id = ?", user.id) }

  delegate :project, to: :phase
  delegate :commission_schemes_roles, to: :commission_scheme

  def self.set_params(params, sort_column, sort_direction)
    order(sort_column + " " + sort_direction).search(params)
  end

  def self.search(params)
    stages = Stage.all
    stages = stages.where("projects.id" => params[:project]) if params[:project].present?
    stages = stages.where("phases.id" => params[:phase]) if params[:phase].present?
    stages = stages.where(id: params[:stage]) if params[:stage].present?
    stages
  end

  def sold_lots
    self.lots.sold.length
  end

  def base_price
    quotient = self.sold_lots / 250
    quotient = quotient.to_i
    self.credit_scheme.price + quotient * 50
  end

  def blueprint_document(selected_lot, controller = nil)
    StageBlueprint.new(self, selected_lot, controller)
  end

  def sold_percentage
    total = self.lots.length
    if total > 0
      (self.lots.sold.length / total) * 100
    else
      0
    end
  end

  def has_blueprint?
    BlueprintStage.exists?(stage_id: self.id)
  end

  def is_assigned(user) # Todo: Optimize as has_promotion
    @assign = StageUser.where(user_id: user.id, stage_id: self.id).exists?
  end

  def has_promotion(promotion)
    self.promotions.exists?(promotion.id)
  end

  def has_contract(contract)
    self.contracts.exists?(contract.id)
  end

  def stage_type?(base_stage_type)
    base_stage_type.to_s == stage_type
  end

  def is_residential?
    self.stage_type == "residential"
  end

  def is_commercial?
    self.stage_type == "commercial"
  end

  def get_stage_type
    if self.is_commercial?
      return "Comercial"
    end

    if self.is_residential?
      "Residencial"
    end
  end

  def parse_receptor_emails
    unless emails.blank?
      self.payment_receptor_emails = emails.split(",").map { |e| e.strip }
    end
  end

  def full_name(divisor = nil)
    divisor = divisor.present? ? " #{divisor} " : " "
    self.show_full_name ? self.phase.name + divisor + self.name : self.name
  end

  def full_path(divisor = " ")
    self.show_full_name ? "#{self.phase.full_path(divisor)}#{divisor}#{self.name}" : "#{self.phase.project.name}#{divisor}#{self.name}"
  end

  def get_availability
    lots = self.lots.includes(:folders)
    lots_with_active_folders = lots.where(id: lots.where(folders: { status: :active }))
    locked_lots = lots.where(status: Lot::STATUS[:LOCKED_SALE])
    unavailable_lots = lots_with_active_folders.or(locked_lots).distinct
    "#{lots.size - unavailable_lots.size} / #{lots.size}"
  end

  def set_order
    self.order = self.phase.stages.length.zero? ? 0 : self.phase.stages.last.order + 1
  end

  def project
    self.phase.project
  end

  def months_to_delivery
    (self.delivery_date.year * 12 + self.delivery_date.month) - (Time.zone.now.year * 12 + Time.zone.now.month) - 1
  end

  def months_to_relative_financing
    months_sum = months_to_delivery + 1
    if Time.zone.now.next_month(months_sum).to_date > delivery_date.to_date
      months_to_delivery
    else
      months_sum
    end
  end

  def down_payment_max_finance
    credit_scheme.relative_down_payment && delivery_date.present? ? months_to_delivery : credit_scheme.max_finance
  end

  def has_additional_concept(additional_concept)
    additional_concepts.exists?(additional_concept.id)
  end

  def reference
    self[:reference] || "00"
  end

  def phase_description_title
    self[:phase_description_title] || "Anexo"
  end

  def stage_description_title
    self[:stage_description_title] || "Anexo"
  end

  def lot_description_title
    self[:lot_description_title] || "Anexo"
  end

  def purchase_conditions_formatted(opening_commission = 0)
    super(
      opening_commission: opening_commission,
      purchase_conditions: purchase_conditions,
      phase_date: phase.start_date,
      stage_date: release_date,
    )
  end

  private

    def pdf_annexes_file_type
      pdf_annexes.attachments.each do |attachment|
        if attachment.blob.content_type != "application/pdf"
          errors.add(:pdf_annexes, :invalid_type)
          break
        end
      end
    end

    def parameterize_slug
      self.slug = slug.parameterize if slug.present?
    end
end
