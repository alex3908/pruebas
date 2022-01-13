# frozen_string_literal: true

json.extract! job_status, :id, :log, :created_at, :updated_at, :status, :error_message
if (job_status.downloadable? || job_status.up_and_downloadable?) && job_status.success? && job_status.file.attached?
  json.merge!({ document: rails_blob_path(job_status.file, disposition: "attachment") })
end
json.merge!({ retry: job_status.pending? })
json.url job_status_url(job_status, format: :json)
