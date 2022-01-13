# frozen_string_literal: true

module OnlinePaymentServicesHelper
  def parse_hash(input_hash)
    if input_hash.kind_of? String
      return JSON.parse(input_hash.gsub("=>", ": ")).to_h
    end

    input_hash
  end
end
