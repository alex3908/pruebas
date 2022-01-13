# frozen_string_literal: true

module Exceptions
  class NetpayApiError < StandardError
    attr_reader :api_response

    def initialize(api_response)
      @api_response = api_response
    end
  end

  class WrongUDID < StandardError; end
  class WrongLotUDID < WrongUDID; end
end
