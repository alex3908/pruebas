# frozen_string_literal: true

class TratoBaseService < RemoteService
  include BaseService

  def get_fields
    [
      { field_name: "api_key", type: FIELD_TYPES[:password] },
      { field_name: "expiration_days", type: FIELD_TYPES[:text] },
      { field_name: "email", type: FIELD_TYPES[:text] },
      { field_name: "password", type: FIELD_TYPES[:password] }
    ]
  end
end
