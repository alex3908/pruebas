# frozen_string_literal: true

class Blueprint < ApplicationRecord
  attr_accessor :file
  LEVEL = { STAGE: "Stage", PHASE: "Phase" }

  belongs_to :level, polymorphic: true

  has_many :blueprint_lots, dependent: :delete_all
  has_many :blueprint_stages, dependent: :delete_all

  has_one_attached :svg_file
  has_one_attached :background

  def svg_file_path
    ActiveStorage::Blob.service.send(:path_for, svg_file.key)
  end

  def has_assigned_lots
    blueprint_lots.where("lot_id IS NOT NULL").any?
  end

  def has_assigned_stages
    blueprint_stages.where("stage_id IS NOT NULL").any?
  end
end
