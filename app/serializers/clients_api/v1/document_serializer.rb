# frozen_string_literal: true

class ClientsApi::V1::DocumentSerializer < ClientsApi::V1::BaseSerializer
  attributes :id,
  :created_at,
  :updated_at,
  :document_template,
  :file_versions

  def file_versions
    ActiveModel::SerializableResource.new(object.file_versions,  each_serializer: ClientsApi::V1::FileVersionSerializer)
  end

  def document_template
    ClientsApi::V1::DocumentTemplateSerializer.new(object.document_template).attributes
  end
end
