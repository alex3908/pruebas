# frozen_string_literal: true

class Annexe_3 < DocumentHandler
  include ActionView::Helpers::TagHelper

  FILE_PATH = "folders/files/annexe_3.html.erb"

  attr_reader :project, :phase, :stage, :lot

  def initialize(*args)
    @lot = args.at(0)
    @stage = @lot.stage
    @phase = @lot.stage.phase
    @project = @lot.stage.phase.project
    @template = @lot.template

    opts = if args.last.class == Hash
      args.last
    else
      {}
    end
    opts[:layout] = "pdf"

    super(FILE_PATH, opts)
  end

  def merged_attributes
    attributes.reverse_merge!(old_attributes)
  end

  def tags_without_value
    template_render(true)
    tags_without_value = []
    @template.errors.each { |error| tags_without_value.push(error.message.gsub("Liquid error: undefined variable", "")) }
    tags_without_value
  end

  def template_render
    @template.render(merged_attributes, filters: [LiquidFilters]).gsub(">", "><span>").gsub("<", "</span><")
  end

  def locals
    html_code_block = template_render
    {
      html_code_block: html_code_block,
    }
  end

  def assigns
    {
      lot: lot
    }
  end

  def attributes
    {
      "lote" => lot_attributes,
    }
  end

  def lot_attributes
    {
      "referencia" => lot.reference,
      "nombre" => lot.name,
      "area" => lot.area,
      "nivel_2" => lot.stage.name,
      "nivel_2_fecha" => lot.stage.release_date,
      "nivel_1" => lot.stage.phase.name,
      "nivel_1_fecha" => lot.stage.phase.start_date,
      "nivel_0" => lot.stage.phase.project.name,
      "norte" => lot.north,
      "sur" => lot.south,
      "este" => lot.east,
      "oeste" => lot.west,
      "noreste" => lot.northeast,
      "sureste" => lot.southeast,
      "noroeste" => lot.northwest,
      "suroeste" => lot.southwest,
      "colinda-norte" => lot.adjoining_north,
      "colinda-sur" => lot.adjoining_south,
      "colinda-este" => lot.adjoining_east,
      "colinda-oeste" => lot.adjoining_west,
      "colinda-noreste" => lot.adjoining_northeast,
      "colinda-sureste" => lot.adjoining_southeast,
      "colinda-noroeste" => lot.adjoining_northwest,
      "colinda-suroeste" => lot.adjoining_southwest,
    }
  end

  def old_attributes
    {
      "nombre-proyecto" => '<span class="text-uppercase">' + project.name + "</span>",
      "numero-de-lote" => lot.name,
      "superficie-de-lote" => lot.area,
      "nombre-fase" => phase.name,
      "nombre-etapa" => stage.name,
      "norte" => tag_present_or_missing(lot.north, "(dato no registrado)"),
      "sur" => tag_present_or_missing(lot.south, "(dato no registrado)"),
      "este" => tag_present_or_missing(lot.east, "(dato no registrado)"),
      "oeste" => tag_present_or_missing(lot.west, "(dato no registrado)"),
      "colinda-norte" => tag_present_or_missing(lot.adjoining_north, "(dato no registrado)"),
      "colinda-sur" => tag_present_or_missing(lot.adjoining_south, "(dato no registrado)"),
      "colinda-este" => tag_present_or_missing(lot.adjoining_east, "(dato no registrado)"),
      "colinda-oeste" => tag_present_or_missing(lot.adjoining_west, "(dato no registrado)"),
    }
  end

  def tag_present_or_missing(tag, error_label)
    if tag.blank?
      return content_tag(:span, error_label, style: "color: red;")
    end
    tag
  end
end
