# frozen_string_literal: true

class JobsCleanupJob < ApplicationJob
  queue_as :low_priority

  def perform(job_id)
    job_status = JobStatus.find_by(id: job_id)
    if job_status.present? && job_status.file.present?
      job_status.file.purge
    end
  end
end
