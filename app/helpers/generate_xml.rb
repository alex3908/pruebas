# frozen_string_literal: true

require "nokogiri"
module GenerateXml
  def generate_xml(data, parent = false, opt = { encoding: "UTF-8" })
    return if data.to_s.empty?
    return unless data.is_a?(Hash)

    unless parent

      root, data = data.length == 1 ? data.shift : ["P", data]
      builder = Nokogiri::XML::Builder.new(opt) do |xml|
        xml.send(root) do
          generate_xml(data, xml)
        end
      end

      return builder.to_xml
    end

    data.each do |label, value|
      if value.is_a?(Hash)
        attrs = value.fetch("@attributes", {})
        text = value.fetch("@text", "")
        parent.send(label, attrs, text) do
          value.delete("@attributes")
          value.delete("@text")
          generate_xml(value, parent)
        end

      elsif value.is_a?(Array)
        value.each do |el|
          el = { label => el }
          generate_xml(el, parent)
        end

      else
        parent.send(label, value)
      end
    end
  end
end
