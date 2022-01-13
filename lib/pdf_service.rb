# frozen_string_literal: true

class PdfService
  @instance = new
  private_class_method :new

  class << self
    attr_reader :instance
  end

  def self.instance
    @instance
  end

  def self.i
    self.instance
  end

  def get_merged_pdf(pdf_base_64_array)
    RestClient.post(gateway_url("/merge_pdfs"), { base64PdfArray: pdf_base_64_array }.to_json, { "x-api-key": ENV["PDF_SERVICE_API_KEY"], content_type: :json, accept: :json }).body
  end

  def set_fit_signature(pdf_base_64)
    RestClient.post(gateway_url("/fit_signature"), { base64Pdf: pdf_base_64 }.to_json, { "x-api-key": ENV["PDF_SERVICE_API_KEY"], content_type: :json, accept: :json }).body
  end

  def html_to_pdf(html, with_margin, with_page_number)
    begin
      html_file = Tempfile.new

      html_file.write(html)
      html_file.close
      body = { with_page_number: with_page_number, with_margin: with_margin, file: File.open(html_file.path), multipart: true }
      response = RestClient.post(gateway_url("/api/v1/html_to_pdf"), body, { "x-api-key": ENV["PDF_SERVICE_API_KEY"] })
    ensure
      html_file.close
      html_file.unlink
    end
    response.body
  end

  def svg_to_png(svg)
    begin
      svg_file = Tempfile.new

      svg_file.write(svg)
      svg_file.close
      body = { file: File.open(svg_file.path), multipart: true }
      response = RestClient.post(gateway_url("/api/v1/svg_to_png"), body, { "x-api-key": ENV["PDF_SERVICE_API_KEY"] })
    ensure
      svg_file.close
      svg_file.unlink
    end
    response.body
  end

  private
    def gateway_url(to_append)
      URI.join(ENV["PDF_SERVICE_URL"], to_append).to_s
    end
end
