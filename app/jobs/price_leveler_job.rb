# frozen_string_literal: true

class PriceLevelerJob < ApplicationJob
  queue_as :default

  def perform(job_status, stage_ids, price)
    stages = Stage.where(id: stage_ids)
    job_status.add_progress!("Actualizando precio ...")
    stages.update_all(price: price)
    job_status.mark_completed!
  end
end
