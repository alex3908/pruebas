# frozen_string_literal: true

class Lot < ApplicationRecord
  include Filterable
  include Rails.application.routes.url_helpers

  belongs_to :stage

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, allow_destroy: true

  has_one :blueprint_lot
  has_many :folders, dependent: :destroy
  has_many :quote_logs, dependent: :destroy

  has_one_attached :chepina
  has_one_attached :map
  has_one_attached :scripture
  has_one_attached :permission
  has_many_attached :pdf_annexes

  validate :pdf_annexes_file_type
  validate :validate_liquid_format

  validates :number, presence: true, numericality: { only_integer: true }
  validates :depth, allow_blank: true, numericality: true
  validates :front, allow_blank: true, numericality: true
  validates :area, allow_blank: true, numericality: true
  validates :price, allow_blank: true, numericality: true
  validates :north, allow_blank: true, numericality: true
  validates :south, allow_blank: true, numericality: true
  validates :east, allow_blank: true, numericality: true
  validates :west, allow_blank: true, numericality: true

  STATUS = { FOR_SALE: 0, RESERVED: 1, SOLD: 2, LOCKED_SALE: 3 }.freeze
  enum status: [:for_sale, :reserved, :sold, :locked_sale]

  def self.search(params)
    lots = Lot.all
    lots = lots.where(status: Lot::STATUS[:FOR_SALE]) if params[:status] == "FOR_SALE"
    lots = lots.where(status: Lot::STATUS[:RESERVED]) if params[:status] == "RESERVED"
    lots = lots.where(status: Lot::STATUS[:SOLD]) if params[:status] == "SOLD"
    lots = lots.where(status: Lot::STATUS[:LOCKED_SALE]) if params[:status] == "LOCKED_SALE"
    lots = lots.where(id: params[:lot]) if params[:lot].present?
    lots
  end

  def stp_clabe(folder_id)
    return unless stage.enterprise.online_payment_services.stp.any?

    stage.enterprise.online_payment_services.stp.take.stp_service.generate_clabe_for_client(folder_id)
  end

  def reference
    project_reference = self.project.reference.upcase
    phase_reference = self.phase.reference.upcase
    stage_reference = self.stage.reference.upcase
    stage_identification = self.stage.is_residential? ? "R" : "C"
    lot_number = "%03d" % self.name.scan(/\d+/).first
    lot_class = self.name.tr("0-9", "")

    "#{project_reference}#{phase_reference}#{stage_reference}#{stage_identification}#{lot_number}#{lot_class}"
  end

  def template
    code = description.present? ? description.to_s : stage.lot_description.to_s

    Liquid::Template.parse(code)
  end

  def validate_liquid_format
    code = description.present? ? description.to_s : stage.lot_description.to_s

    Liquid::Template.parse(code)
  rescue Liquid::SyntaxError
    errors.add(:value, "El formato del anexo es incorrecto, revisa tus variables.")
  end

  def has_blueprint?
    BlueprintLot.exists?(lot_id: self.id)
  end

  def can_reactivate?
    # It can be reactivated if the lot is for sale and the stage has no blueprint or the stage has blueprint and the lot is assigned
    self.for_sale? && ((self.stage.blueprint.nil?) || (self.stage.blueprint.present? && self.blueprint_lot.present?))
  end

  def has_folder?
    Folder.exists?(lot_id: self.id)
  end

  def price_with_additional
    if fixed_price.present?
      fixed_price / area
    elsif price.present?
      stage.price + price
    else
      stage.price
    end
  end

  def total_price(price = nil)
    if price.present?
      price * area
    else
      price_with_additional * area
    end
  end

  def key_label
    return "locked_sale" if locked_sale? && Current.user&.can?(:lock, Lot)
    return "sold" if locked_sale?

    folder = folders.active.first
    return status unless folder.present?
    self.class.statuses.invert[folder.step.lot_status]
  end

  def status_label
    return I18n.t("activerecord.attributes.lot.statuses.locked_sale") if locked_sale? && Current.user&.can?(:lock, Lot)
    return I18n.t("activerecord.attributes.lot.statuses.sold") if locked_sale?
    folder = folders.active.first
    return I18n.t("activerecord.attributes.lot.statuses.#{status}") unless folder.present?
    return I18n.t("activerecord.attributes.lot.statuses.reserved") unless folder.step.is_last_one?
    I18n.t("activerecord.attributes.lot.statuses.sold")
  end

  def status_label_map
    return "Vendido" if locked_sale?
    folder = folders.active.first
    return "Disponible" unless folder.present?
    return "Reservado" unless folder.step.is_last_one?
    "Vendido"
  end

  def chepina_nil
    if self.chepina.attached?
      self.chepina
    else
      "no-image.png"
    end
  end

  def chepina_attached_path
    if self.chepina.attached?
      rails_blob_path(self.chepina, disposition: "attachment", only_path: true)
    else
      "no-image.png"
    end
  end

  def chepina_path
    if self.chepina.attached?
      rails_blob_path(self.chepina, only_path: true)
    else
      "no-image.png"
    end
  end

  def full_name
    "#{self.stage.full_name("/")} / #{self.stage.phase.project.lot_entity_name} #{self.name}"
  end

  def full_path(divisor = " ")
    "#{self.stage.full_path(divisor)}#{divisor}#{self.stage.phase.project.lot_entity_name} #{self.name}"
  end

  def name
    self.label.present? ? self.number.to_s + " " + self.label : self.number.to_s
  end

  def phase
    self.stage.phase
  end

  def project
    self.stage.phase.project
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
end
