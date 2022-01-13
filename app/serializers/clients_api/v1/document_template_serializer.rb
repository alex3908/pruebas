# frozen_string_literal: true

class ClientsApi::V1::DocumentTemplateSerializer < ClientsApi::V1::BaseSerializer
  attributes :id, :name, :requires_approval, :doc_type, :client_type
end
