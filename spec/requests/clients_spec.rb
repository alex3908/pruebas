# frozen_string_literal: true

require "rails_helper"

describe Client, type: :request do
  let(:user_clients) { }
  describe "GET /clients_api/v1/salesman" do
    before { get "/clients_api/v1/salesman" }
    it "return client salesman" do
      expect(JSON.parse(response.body)).not_to be_empty
    end
    it "returns status code 200" do
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /clients_api/v1/account_statuses" do
    before { get "/clients_api/v1/account_statuses" }

    it "return account_statuses urls" do
      expect(JSON.parse(response.body)).not_to be_empty
    end

    it "returns status code 200" do
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /clients_api/v1/pending_payments" do
    before { get "/clients_api/v1/pending_payments" }

    it "return pending_payments urls" do
      expect(JSON.parse(response.body)).not_to be_empty
    end

    it "returns status code 200" do
      expect(response).to have_http_status(200)
    end
  end


  describe "GET /clients_api/v1/customer_service_user" do
    before { get "/clients_api/v1/customer_service_user" }

    it "return pending_payments urls" do
      expect(JSON.parse(response.body)).not_to be_empty
    end

    it "returns status code 200" do
      expect(response).to have_http_status(200)
    end
  end

  it "returns the customer service specialist of the client" do
    get clients_api_with_version("customer_service")
    expect(JSON.parse(response.body)).not_to be_empty
  end
end
