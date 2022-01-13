# frozen_string_literal: true

class API::V1::FolderSerializer < API::V1::BaseSerializer
  attributes :rid, :discount_id, :lot_id, :client_id, :user_id
end
