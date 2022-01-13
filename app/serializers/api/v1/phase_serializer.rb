# frozen_string_literal: true

class API::V1::PhaseSerializer < API::V1::BaseSerializer
  attributes :id, :rid, :name, :start_date, :project_id, :created_at, :updated_at
end
