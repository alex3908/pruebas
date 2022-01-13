# frozen_string_literal: true

class Phase < ApplicationRecord
  acts_as_paranoid
  include RailsSortable::Model
  include Filterable

  has_paper_trail

  scope :api_format, -> () {
    select(:id, :name, :start_date)
  }

  set_sortable :order

  belongs_to :project

  has_one :blueprint, as: :level, dependent: :destroy

  has_many :stages, -> { order(order: :asc) }, dependent: :destroy

  before_create :set_order

  before_validation :parameterize_slug
  validates :slug, uniqueness: { scope: :project_id }

  def self.search(params)
    phase = Phase.all
    phase = phase.where("phases.id" => params[:phase]) if params[:phase].present?
    phase
  end

  def blueprint_document(selected_stage, controller = nil)
    PhaseBlueprint.new(self, selected_stage, controller)
  end

  def set_order
    self.order = self.project.phases.length.zero? ? 0 : self.project.phases.last.order + 1
  end

  def full_path(divisor = " ")
    "#{self.project.name}#{divisor}#{self.name}"
  end

  def reference
    self[:reference] || "00"
  end

  private

    def parameterize_slug
      self.slug = slug.parameterize if slug.present?
    end
end
