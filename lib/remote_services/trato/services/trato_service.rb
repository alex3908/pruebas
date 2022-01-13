# frozen_string_literal: true

class TratoService < TratoBaseService
  include Exceptions

  GATEWAY_URLS = {
    "production" => "https://enterprise.api.trato.io",
    "test" => "https://enterprise-stage.api.trato.io"
  }

  STATUSES = { SENT_TO_SIGN: "SENT_TO_SIGN", CANCELED: "CANCELED", RECEIVED_SIGNED: "RECEIVED_SIGNED", EXPIRED: "EXPIRED", FINALIZED: "FINALIZED" }


  def init_process(document_name, base64_document, external_id, signers, sign_in_order, shield_level_three_message)
    signers = signers.map.with_index  { |signer, index|parse_signer(signer, index) }
    today = Time.now
    expiration_date = today + expiration_days.days
    url = gateway_url("/api/v2/create/contract")
    body = {
      name: document_name,
      language: "es",
      expiryUndefined: false,
      expiryStartDate: today.strftime("%Y-%m-%d"),
      expiryEndDate: expiration_date.strftime("%Y-%m-%d"),
      externalId: external_id,
      showSignLinks: true,
      notificationType: "none",
      ownerSelfSign: false,
      signInOrder: sign_in_order,
      signatureType: "autograph",
      stampNom: true,
      file: "data:application/pdf;base64,#{base64_document}",
      shield3Statement: shield_level_three_message,
      participants: signers
    }
    document_response = RestClient.post(url, body.to_json, { apiKey: api_key, content_type: :json, accept: :json })
    JSON.parse document_response
  rescue RestClient::Exception => ex
    data = check_data(ex&.response&.body)
    Bugsnag.notify(ex) do |report|
      report.add_tab(:trato_error_request, { url: url, body: body })
      report.add_tab(:trato_error_response, data)
    end
    data
  end

  def get_status(contract_id)
    url = gateway_url("/api/contract/status/#{contract_id}")
    document_response = RestClient.get(url, Authorization: get_bearer_jwt(authorize_bearer))
    JSON.parse document_response
  rescue RestClient::Exception => ex
    data = check_data(ex&.response&.body)
    Bugsnag.notify(ex) do |report|
      report.add_tab(:trato_error_request, { url: url })
      report.add_tab(:trato_error_response, data)
    end
    data
  end

  def cancel_process(contract_id)
    url = gateway_url("/api/contract/cancel/#{contract_id}")
    cancel_response = RestClient.delete(url, Authorization: get_bearer_jwt(authorize_bearer))
    cancel_response = JSON.parse cancel_response
    cancel_response["success"]
  rescue RestClient::Exception => ex
    data = check_data(ex&.response&.body)
    Bugsnag.notify(ex) do |report|
      report.add_tab(:trato_error_request, { url: url })
      report.add_tab(:trato_error_response, data)
    end
    false
  end

  def finalize_process(contract_id)
    url = gateway_url("/api/contract/finalize/#{contract_id}")
    document_response = HTTParty.post(url, headers: { Authorization: get_bearer_jwt(authorize_bearer) })
    response = JSON.parse document_response.body
    response
  rescue HTTParty::Error => ex
    Bugsnag.notify(ex) do |report|
      report.add_tab(:trato_error_request, { url: url })
      report.add_tab(:trato_error_response, ex)
    end
  end

  def authorize_bearer
    url = gateway_url("/api/authentication/token")
    user_info = {
      email: user_email,
      password: user_password
    }
    authorization_response = RestClient.post(url, user_info.to_json, { content_type: :json, accept: :json })
    authorization_response = JSON.parse authorization_response
    authorization_response
  rescue RestClient::Exception => ex
    data = check_data(ex&.response&.body)
    Bugsnag.notify(ex) do |report|
      report.add_tab(:trato_error_request, { url: url, user_info: user_info })
      report.add_tab(:trato_error_response, data)
    end
    raise ex
  end

  def get_participant_status(contract_id, participant_id)
    url = gateway_url("/api/contract/participant/#{contract_id}/#{participant_id}")
    document_response = RestClient.get(url, Authorization: get_bearer_jwt(authorize_bearer))
    JSON.parse document_response
  rescue RestClient::Exception => ex
    data = check_data(ex&.response&.body)
    Bugsnag.notify(ex) do |report|
      report.add_tab(:trato_error_request, { url: url })
      report.add_tab(:trato_error_response, data)
    end
    raise ex
  end

  def list_contracts
    url = gateway_url("/api/list/contracts")
    document_response = RestClient.get(url, { apiKey: api_key, content_type: :json, accept: :json })
    JSON.parse document_response
  rescue RestClient::Exception => ex
    data = check_data(ex&.response&.body)
    Bugsnag.notify(ex) do |report|
      report.add_tab(:trato_error_request, { url: url })
      report.add_tab(:trato_error_response, data)
    end
    {}
  end

    private
      def gateway_url(to_append)
        URI.join(GATEWAY_URLS[mode], to_append).to_s
      end

      def mode
        environment
      end

      def api_key
        properties["api_key"].strip
      end

      def expiration_days
        properties["expiration_days"].to_i
      end

      def user_email
        properties["email"].strip
      end

      def user_password
        properties["password"].strip
      end

      def parse_signer(signer, order)
        {
          obligation: "individual",
          name: signer[:name],
          last_name: signer[:last_name],
          label: signer[:role],
          email: signer[:email],
          requestAgreement: signer[:is_shield_level_three],
          signatures: parse_coordinates(signer[:coordinates]),
          signOrder: order,
          isNotNegotiator: signer[:isNotNegotiator],
          isNotSigner: signer[:isNotSigner],
        }
      end

      def parse_coordinates(signature_coordinates)
        signature_coordinates.map { |signature_coordinate|{
          page: signature_coordinate[:page].to_i,
          top: 723 - signature_coordinate[:y].to_i,
          left: signature_coordinate[:x].to_i - 72.5,
          width: 150,
          height: 75,
          customSize: true
        }
       }
      end

      def get_bearer_jwt(authorize_response)
        authorize_response["success"] ? "Bearer #{authorize_response["jwt"]}" : ""
      end

      def check_data(data)
        JSON.parse(data)
      rescue JSON::ParserError
        data
      end
end
