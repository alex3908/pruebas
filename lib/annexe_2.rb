# frozen_string_literal: true

class Annexe_2 < DocumentHandler
  attr_reader :lot

  FILE_PATH = "folders/files/annexe_2.html.erb"

  def initialize(*args)
    @lot = args.at(0)

    opts = if args.last.class == Hash
      args.last
    else
      {}
    end
    opts[:layout] = "pdf"


    super(FILE_PATH, opts)
  end

  private

    def locals
      if lot.stage.blueprint
        blueprint_stage = lot.stage.blueprint_document(lot, self.controller).render_to_string(layout: false)
      end

      {
        blueprint_stage: blueprint_stage || nil,
        lot: lot,
        stage: lot.stage
      }
    end
end
