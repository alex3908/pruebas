# frozen_string_literal: true

class ClientsApi::V1::PendingPaymentsSerializer < ClientsApi::V1::BaseSerializer
  attributes :class

  def class
    object.class
  end
end
