# frozen_string_literal: true

module EntityNamesConcern
  extend ActiveSupport::Concern
  def set_project_entity_names_by_project
    set_entity_names(@project)
  end

  def set_project_entity_names_by_folder
    set_entity_names(@folder.lot.project)
  end

    private

      def set_entity_names(project)
        @project_plural = project.project_entity_plural
        @project_singular = project.project_entity_name
        @phase_plural = project.phase_entity_plural
        @phase_singular = project.phase_entity_name
        @stage_plural = project.stage_entity_plural
        @stage_singular = project.stage_entity_name
        @lot_plural = project.lot_entity_plural
        @lot_singular = project.lot_entity_name
      end
end
