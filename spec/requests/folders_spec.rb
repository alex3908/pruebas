# frozen_string_literal: true

require "rails_helper"
include ClientApiHandler

describe "test all folder controller methods", type: :request do
  it "returns the active folders of the client" do
    get clients_api_with_version("folders")
    expect(JSON.parse(response.body)).not_to be_empty
  end

  it "returns the stp clabe of the folder" do
    get clients_api_with_version("stp/1")
    expect(JSON.parse(response.body)).not_to be_empty
  end
end
