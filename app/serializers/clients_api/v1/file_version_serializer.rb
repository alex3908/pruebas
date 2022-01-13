# frozen_string_literal: true

class ClientsApi::V1::FileVersionSerializer < ClientsApi::V1::BaseSerializer
  attributes :id,
  :created_at,
  :updated_at,
  :url

  def url
    url_for(object.file)
  end
end
