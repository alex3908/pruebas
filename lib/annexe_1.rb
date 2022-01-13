# frozen_string_literal: true

class Annexe_1 < DocumentHandler
  attr_reader :stage

  FILE_PATH = "folders/files/annexe_1.html.erb"

  def initialize(*args)
    @stage = args.at(0)

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
      if stage.phase.blueprint
        blueprint_phase = stage.phase.blueprint_document(stage, self.controller).render_to_string(layout: false)
      end

      {
        blueprint_phase: blueprint_phase || nil,
        stage: stage
      }
    end
end
