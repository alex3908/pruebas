#! /usr/bin/env ruby
# frozen_string_literal: true

require "nokogiri"
require "open-uri"

class Map
  def initialize(svg_file)
    @svg_file = File.open(svg_file)
  end


  def get_styles
    doc = Nokogiri::HTML(open(@svg_file))
    nodes = doc.search("//style")
    nodes[0]
  end

  def read_reference_data(reference)
    blueprint_lots = Array.new

    doc = Nokogiri::HTML(open(@svg_file))

    doc.css("#lots> *").each do |lot|
      blueprint_lots.push(get_lot_data(lot, reference))
    end
    blueprint_lots
  end

  def read_extra_data
    blueprint_extra_data = Array.new

    doc = Nokogiri::HTML(open(@svg_file))
    blueprint_extra_data = blueprint_extra_data + get_data_by_id("texts", doc)
    blueprint_extra_data = blueprint_extra_data + get_data_by_id("ground", doc)
    blueprint_extra_data = blueprint_extra_data + get_data_by_id("fillings", doc)
    blueprint_extra_data + get_data_by_id("flora", doc)
  end

  def read_view_box
    doc = Nokogiri::HTML(open(@svg_file))
    nodes = doc.search("//svg")
    if nodes[0].has_attribute?("viewbox")
      nodes[0].attribute("viewbox").value
    else
      ""
    end
  end

  def read_style
    doc = Nokogiri::HTML(open(@svg_file))
    nodes = doc.search("//svg")
    if nodes[0].has_attribute?("style")
      nodes[0].attribute("style").value
    else
      ""
    end
  end

  private

    # Attributes that can be read only
    attr_reader :svg_file

    def get_data_by_id(id, doc)
      blueprint_extra_data = Array.new
      doc.css("#" + id + "> *").each do |extra|
        blueprint_extra = BlueprintExtra.new
        blueprint_extra.name = id
        blueprint_extra.html_type = extra.name
        if extra.has_attribute?("class")
          blueprint_extra.html_class = extra.attribute("class").value
        end

        if extra.name == "polygon"
          blueprint_extra.points = extra.attribute("points").value if extra.has_attribute?("points")

        elsif extra.name == "path"
          blueprint_extra.d = extra.attribute("d").value if extra.has_attribute?("d")

        elsif extra.name == "polyline"
          blueprint_extra.points = extra.attribute("points").value if extra.has_attribute?("points")

        elsif extra.name == "rect"
          blueprint_extra.x = extra.attribute("x").value if extra.has_attribute?("x")
          blueprint_extra.y = extra.attribute("y").value if extra.has_attribute?("y")
          blueprint_extra.width = extra.attribute("width").value if extra.has_attribute?("width")
          blueprint_extra.height = extra.attribute("height").value if extra.has_attribute?("height")
          blueprint_extra.transform = extra.attribute("transform").value.to_s if extra.has_attribute?("transform")
        elsif extra.name == "line"
          blueprint_extra.x1 = extra.attribute("x1").value if extra.has_attribute?("x1")
          blueprint_extra.x2 = extra.attribute("x2").value if extra.has_attribute?("x2")
          blueprint_extra.y1 = extra.attribute("y1").value if extra.has_attribute?("y1")
          blueprint_extra.y2 = extra.attribute("y2").value if extra.has_attribute?("y2")
        elsif extra.name == "ellipse"
          blueprint_extra.cx = extra.attribute("cx").value if extra.has_attribute?("cx")
          blueprint_extra.cy = extra.attribute("cy").value if extra.has_attribute?("cy")
          blueprint_extra.rx = extra.attribute("rx").value if extra.has_attribute?("rx")
          blueprint_extra.ry = extra.attribute("ry").value if extra.has_attribute?("ry")
        elsif extra.name == "circle"
          blueprint_extra.cx = extra.attribute("cx").value if extra.has_attribute?("cx")
          blueprint_extra.cy = extra.attribute("cy").value if extra.has_attribute?("cy")
          blueprint_extra.r = extra.attribute("r").value if extra.has_attribute?("r")
        end
        blueprint_extra_data.push(blueprint_extra)
      end
      blueprint_extra_data
    end

    def get_lot_data(lot, reference)
      blueprint_lot = reference.new
      blueprint_lot.html_type = lot.name

      if lot.has_attribute?("class")
        blueprint_lot.html_class = lot.attribute("class").value
      end

      if lot.name == "polygon"
        blueprint_lot.points = lot.attribute("points").value.to_s if lot.has_attribute?("points")

      elsif lot.name == "path"
        blueprint_lot.d = lot.attribute("d").value.to_s if lot.has_attribute?("d")

      elsif lot.name == "polyline"
        blueprint_lot.points = lot.attribute("points").value.to_s if lot.has_attribute?("points")

      elsif lot.name == "rect"
        blueprint_lot.x = lot.attribute("x").value.to_s if lot.has_attribute?("x")
        blueprint_lot.y = lot.attribute("y").value.to_s if lot.has_attribute?("y")
        blueprint_lot.width = lot.attribute("width").value.to_s if lot.has_attribute?("width")
        blueprint_lot.height = lot.attribute("height").value.to_s if lot.has_attribute?("height")
        blueprint_lot.transform = lot.attribute("transform").value.to_s if lot.has_attribute?("transform")
      end

      blueprint_lot
    end
end
