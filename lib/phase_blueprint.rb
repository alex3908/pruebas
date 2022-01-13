# frozen_string_literal: true

# frozen_string_literal: true

class PhaseBlueprint < BlueprintDocument
  FILE_PATH = "blueprints/_blueprint_for_phase.html"

  attr_reader :phase, :selected_stage

  def initialize(phase, selected_stage, controller)
    @phase = phase
    @selected_stage = selected_stage
    super(phase, FILE_PATH, controller)
  end

  protected

    def locals
      {
        project: phase.project,
        phase: phase,
        stages: [],
        extras: extras,
        selected_stage: selected_stage,
        assignable: false,
        texts: true,
        with_styles: true
      }
    end
end
