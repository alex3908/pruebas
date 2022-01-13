# frozen_string_literal: true

class JobStatus < ApplicationRecord
  attribute :log, :string, default: ""
  attribute :status, :integer, default: 0

  belongs_to :user
  belongs_to :job, class_name: "Delayed::Job", foreign_key: "job_id", required: false
  has_one_attached :file

  scope :not_expired, -> { where("expires_at IS NULL OR expires_at > (?)", Time.zone.now) }
  scope :completed, -> { where(status: :success) }

  enum job_class: { price_leveler: "PriceLeveler" }
  enum status: { pending: 0, success: 1, error: 2, canceled: 4 }
  enum action: { downloadable: 0, uploadable: 1, up_and_downloadable: 2, task: 3 }

  store_accessor :job_data

  def add_progress!(message)
    update!(
      log: log << "\n==> " << message
    )
  end

  def mark_completed!
    update!(
      status: :success,
      expires_at: Time.zone.now + 24.hours,
      log: log << "\n\n---\n\n" << "Completado"
    )
    JobsCleanupJob.set(wait_until: expires_at).perform_later(id)
  end

  def mark_failed!(error_message)
    update!(status: :error, error_message: error_message)
  end

  def log_error!(error)
    update!(
      log: log << "\n\n---\n\nERROR: " << error.to_s
    )
  end

  def file_name
    name.downcase.gsub(" ", "-")
  end

  def cancel!
    if pending?
      ActiveJob::Base.cancel_by(provider_job_id: job_id)
      update!(status: :canceled)
    end
  end
end
