# frozen_string_literal: true

class ClientsApi::V1::FolderSerializer < ClientsApi::V1::BaseSerializer
  attributes :id,
  :project,
  :phase,
  :stage,
  :lot,
  :plan_name,
  :step,
  :status,
  :buyer,
  :start_date,
  :approved_date,
  :total_sale

  def project
    object.project.attributes.symbolize_keys.slice(:id, :name)
  end

  def phase
    object.phase.attributes.symbolize_keys.slice(:id, :name)
  end

  def stage
    object.stage.attributes.symbolize_keys.slice(:id, :name)
  end

  def lot
    object.lot.attributes.symbolize_keys.slice(:id, :identification_name)
  end

  def step
    object.step.attributes.symbolize_keys.slice(:id, :name)
  end

  def plan_name
    object.payment_scheme.name
  end
end
