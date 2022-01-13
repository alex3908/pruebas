# frozen_string_literal: true

module PhasesHelper
  def enable_phase_button_availibility?(phase)
    phase.slug.present? && phase.project.slug.present?
  end

  def message_miss_phase_slug_for_url(phase)
    message = "Falta el dato de slug en"
    message += " #{Project.model_name.human}" unless phase.project.slug.present?
    message += " #{Phase.model_name.human}" unless phase.slug.present?
    message
  end
end
