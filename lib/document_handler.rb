# frozen_string_literal: true

require "combine_pdf"
require "wicked_pdf"

class DocumentHandler
  attr_accessor :controller, :path, :assigns, :locals, :layout

  def initialize(*args)
    @path = args.at(0)
    @assigns ||= args.at(1)
    @locals ||= args.at(2)

    opts = if args.last.class == Hash
      args.last
    else
      {}
    end

    @controller = opts[:controller] || ApplicationController.new
    @layout = opts[:layout] || false
  end

  def render_to_string(opts = {})
    controller.render_to_string(path, layout: layout, assigns: assigns, locals: locals)
  end

  def to_pdf(*args)
    with_page_number = args.include?(:with_page_number)
    with_margin = args.include?(:with_margin)
    return_file = args.include?(:return_file)
    use_grover = args.include?(:use_grover)

    if use_grover
      @layout = "pdf_grover" if @layout.present?
      PdfService.instance.html_to_pdf(render_to_string, with_margin, with_page_number)
    else
      WickedPdf.new.pdf_from_string(
        render_to_string,
        lowquality: true,
        zoom: 1,
        dpi: 75,
        page_size: "Letter",
        return_file: return_file,
        footer: (with_page_number) ? { right: "[page] / [topage]", font_name: "Arial", font_size: 9 } : {},
        margin: (with_margin) ? { top: "50px", bottom: "50px", left: "50px", right: "50px" } : { top: 0, bottom: 0, left: 0, right: 0 }
      )
    end
  end

  def for_combine
    CombinePDF.parse(to_pdf)
  end

  def to_pdf_base_64
    Base64.strict_encode64(to_pdf)
  end

  def join(*args)
    combine_pdf = CombinePDF.new
    if args.last.is_a? Hash
      opts = args.pop
    end

    combine_pdf << CombinePDF.parse(WickedPdf.new.pdf_from_string(render_to_string))

    args.each do |doc|
      combine_pdf << CombinePDF.parse(WickedPdf.new.pdf_from_string(doc))
    end

    combine_pdf.number_pages(opts) unless opts.nil?
    combine_pdf
  end
end
