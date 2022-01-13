# frozen_string_literal: true

require "rails_helper"

describe CashFlow, type: :request do
  describe "GET /clients_api/v1/get_invoices" do
    before { get "/clients_api/v1/get_invoices" }
    it "return client get_invoices" do
      expect(JSON.parse(response.body)).not_to be_empty
    end
    it "returns status code 200" do
      expect(response).to have_http_status(200)
    end
  end
end
