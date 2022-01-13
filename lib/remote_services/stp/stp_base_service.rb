# frozen_string_literal: true

class StpBaseService < RemoteService
  include BaseService

  def get_fields
    [
      :key_code
    ]
  end
end
