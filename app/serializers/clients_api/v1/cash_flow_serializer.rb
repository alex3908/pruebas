# frozen_string_literal: true

class ClientsApi::V1::CashFlowSerializer < ClientsApi::V1::BaseSerializer
  include CashFlowHelper, DateHelper
  attributes :id, :is_canceled, :status, :date, :concepts, :amount

  def is_canceled
    object.canceled?
  end

  def status
    object.status_label
  end

  def date
    only_date(object.date)
  end

  def concepts
    concepts_array(object.concept)
  end
end
