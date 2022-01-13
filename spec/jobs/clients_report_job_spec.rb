# frozen_string_literal: true

require "rails_helper"

RSpec.describe ClientsReportJob, type: :job do
  include ActiveJob::TestHelper

  before(:all) do
    @user = create(:user)
  end

  subject(:job) do
    job_status = JobStatus.create!(name: "Reporte de clientes - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: @user, status: "pending")
    described_class.perform_later(job_status, {
      director_node: "2",
      vice_director_node: "3",
      manager_node: "",
      from_date: "28/07/2021",
      to_date: "28/07/2021",
      lead_source: "1",
      concept: {
        '1': "1",
        '2': ""
      }
    })
  end

  it "queues the job" do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "handles no results error" do
    perform_enqueued_jobs { job }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
