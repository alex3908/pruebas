# frozen_string_literal: true

class StageBlueprint < BlueprintDocument
  FILE_PATH = "blueprints/_blueprint_for_stage.html"

  attr_accessor :stage, :selected_lot

  def initialize(stage, selected_lot, controller)
    @stage = stage
    @selected_lot = selected_lot
    super(stage, FILE_PATH, controller)
  end

  protected

    def locals
      {
        project: stage.phase.project,
        phase: stage.phase,
        stage: stage,
        selected_lot: selected_lot,
        extras: extras,
        sale_map: false,
        show_tooltip: false,
        assignable: false,
        link: false,
        texts: true,
        with_styles: true
      }
    end
end
