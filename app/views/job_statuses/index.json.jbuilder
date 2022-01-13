# frozen_string_literal: true

json.array! @job_statuses, partial: "job_statuses/job_status", as: :job_status
