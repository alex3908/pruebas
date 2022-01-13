# frozen_string_literal: true

require "rails_helper"
include ClientApiHandler

describe "test all payment methods controller methods", type: :request do
  it "returns all payment methods" do
    get clients_api_with_version("payment_methods")
    expect(JSON.parse(response.body)).not_to be_empty
  end
end
