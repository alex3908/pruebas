# frozen_string_literal: true

require "rails_helper"
include ClientApiHandler

describe "test all document controller methods", type: :request do
  it "returns the documents of the client" do
    get clients_api_with_version("documents")
    expect(JSON.parse(response.body)).not_to be_empty
  end
end
