# frozen_string_literal: true

# config/initializers/delayed_job_config.rb
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 10
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 1.hour
Delayed::Worker.read_ahead = 10
Delayed::Worker.default_queue_name = "default"
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.raise_signal_exceptions = :term
Delayed::Worker.logger = Logger.new(File.join(Rails.root, "log", "delayed_job.log"))
Delayed::Worker.queue_attributes = {
  default:       { priority: 20 },
  high_priority: { priority: 1 },
  low_priority:  { priority: 75 },
}
