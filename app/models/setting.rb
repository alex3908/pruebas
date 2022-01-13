# frozen_string_literal: true

class Setting < ApplicationRecord
  scope :permitted, ->(is_permitted) do
    if is_permitted
      all
    else
      where(hidden: false)
    end
  end

  enum data_type: { integer: "integer", percentage: "percentage", string: "string", float: "float", boolean: "boolean", csv: "csv", html: "html" }

  TYPE_LABELS = {
    "integer" => "Entero",
    "percentage" => "Porcentaje",
    "float" => "Decimal",
    "string" => "Texto",
    "boolean" => "Bandera",
    "csv" => "Separado por comas",
    "html" => "Editor de Texto"
  }.freeze

  CONCEPTS = {
      "general" => "Generales",
      "commission" => "Comisiones",
      "structure" => "Multinivel",
      "enterprise" => "Empresa",
  }.freeze

  def self.set_params(params, sort_column, sort_direction)
    order(sort_column + " " + sort_direction).search(params)
  end

  def self.search(params)
    settings = Setting.all
    settings = settings.where("LOWER(label) LIKE LOWER(?)", "%#{params[:label].tr(" ", "%")}%".delete(" \t\r\n")) if params[:label].present?
    settings = settings.where(data_type: params[:data_type]) if params[:data_type].present?
    settings = settings.where(concept: params[:concept]) if params[:concept].present?
    settings
  end

  def data_type_label
    Setting::TYPE_LABELS[data_type]
  end

  def concept_label
    Setting::CONCEPTS[concept]
  end

  def convert
    return nil unless value.present? && data_type.present?
    if data_type == "boolean"
      ["true", "1", 1].include? value
    elsif data_type == "integer"
      value.to_i
    elsif data_type == "percentage"
      value.to_f / 100
    elsif data_type == "float"
      value.to_f
    elsif data_type == "string"
      value
    end
  end

  def parse
    return nil unless value.present? && data_type.present?
    if data_type == "boolean"
      ["true", "1", 1].include? value
    elsif data_type == "integer"
      value.to_i
    elsif data_type == "percentage"
      value.to_f
    elsif data_type == "float"
      value.to_f
    elsif data_type == "string"
      value
    end
  end
end
