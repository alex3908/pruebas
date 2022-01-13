# frozen_string_literal: true

class BlueprintDocument < DocumentHandler
  attr_reader :source, :extras

  def initialize(source, path, controller)
    @source = source
    @extras = extras
    super(path, controller: controller)
  end

  def render_to_string(opts = {})
    super(layout: false).gsub(/\n/, "")
  end

  def to_png
    PdfService.instance.svg_to_png(render_to_string)
  end

  protected

    def extras
      extra = []
      ActiveStorage::Downloader.new(source.blueprint.svg_file).download_blob_to_tempfile do |file|
        map = Map.new(file.path)
        extra = map.read_extra_data
      end

      extra
    end
end
