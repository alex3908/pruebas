# frozen_string_literal: true

namespace :set_release_date do
  desc "Run set_release_date task"

  task run: :environment do
    Stage.where(start_date_by: Stage::START_DATE_BY[:PHASE_DATE]).each do |stage|
      stage.update(release_date: stage.phase.start_date, start_date_by: Stage::START_DATE_BY[:STAGE_DATE])
    end
  end
end
  