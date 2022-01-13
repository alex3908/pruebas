# frozen_string_literal: true

module ClientApiHandler
  extend ActiveSupport::Concern

  def clients_api_with_version(endpoint)
    "/clients_api/v1/" + endpoint
  end
end
