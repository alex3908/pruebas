# frozen_string_literal: true

class Project < ApplicationRecord
  acts_as_paranoid
  include RailsSortable::Model
  include Filterable
  include Rails.application.routes.url_helpers

  set_sortable :order
  has_many :phases, -> { order(order: :asc) }, dependent: :destroy
  has_many :stages, through: :phases
  has_many :project_users, dependent: :destroy
  has_many :users, through: :project_users

  has_one_attached :macroplane
  has_one_attached :logo
  has_one_attached :background
  has_many_attached :templates

  scope :api_format, -> () {
    where(active: true).select(:id, :name, :email, :phone, :quotation)
  }

  before_create :set_order
  before_validation :parameterize_slug
  validates :slug, uniqueness: true, allow_blank: false

  def self.search(params)
    projects = Project.all
    projects = projects.where(id: params[:project]) if params[:project].present?
    projects
  end

  def lots_sold
    @stages = Stage.where(project_id: self.id).includes(:lots)
    @sold = 0
    @lots = 0

    @stages.each do |stage|
      @sold += stage.lots.sold.length
      @lots += stage.lots.length
    end

    "#{@sold}/#{@lots}"
  end

  def macroplane_nil
    if self.macroplane.attached?
      self.macroplane
    else
      "no-image.png"
    end
  end

  def logo_nil
    if self.logo.attached?
      self.logo
    else
      "no-image.png"
    end
  end

  def logo_attached_path
    if self.logo.attached?
      rails_blob_path(self.logo, disposition: "attachment", only_path: true)
    else
      "no-image.png"
    end
  end

  def background_nil
    if self.background.attached?
      self.background
    else
      "no-image.png"
    end
  end

  def is_assigned(user) # Todo: Optimize as User.has_promotion
    @assign = ProjectUser.where(user_id: user.id, project_id: self.id)
    @assign.count > 0
  end

  def set_order
    projects = Project.all.order(order: :asc)
    self.order = projects.length.zero? ? 0 : projects.last.order + 1
  end

  def project_entity_name
    self[:project_entity_name] || Setting.find_by(key: "project_singular").try(:convert) || "Proyecto"
  end

  def phase_entity_name
    self[:phase_entity_name] || Setting.find_by(key: "phase_singular").try(:convert) || "Fase"
  end

  def stage_entity_name
    self[:stage_entity_name] || Setting.find_by(key: "stage_singular").try(:convert) || "Etapa"
  end

  def lot_entity_name
    self[:lot_entity_name] || Setting.find_by(key: "lot_singular").try(:convert) || "Lote"
  end

  def project_entity_plural
    self.project_entity_name.pluralize(:es)
  end

  def phase_entity_plural
    self.phase_entity_name.pluralize(:es)
  end

  def stage_entity_plural
    self.stage_entity_name.pluralize(:es)
  end

  def lot_entity_plural
    self.lot_entity_name.pluralize(:es)
  end

  def lighten_color(amount)
    hex_color = self.color.gsub("#", "")
    rgb = hex_color.scan(/../).map { |color| color.hex }
    rgb[0] = [(rgb[0].to_i + 255 * amount).round, 255].min
    rgb[1] = [(rgb[1].to_i + 255 * amount).round, 255].min
    rgb[2] = [(rgb[2].to_i + 255 * amount).round, 255].min
    "#%02x%02x%02x" % rgb
  end

  def reference
    self[:reference] || "00"
  end

  private

    def parameterize_slug
      self.slug = slug.parameterize if slug.present?
    end
end
