# frozen_string_literal: true

class Webhook::ClientsController < Webhook::BaseController
  before_action :validate_hubspot_request, :validate_client_duplicity, :find_hubspot_owner, only: [:create]

  # POST
  def create
    lastname = params.dig(:properties, :lastname, :value).split(" ")
    first_surname = lastname.shift
    second_surname = lastname.join(" ")

    client = Client.new
    client.name = params.dig(:properties, :firstname, :value)
    client.first_surname = first_surname
    client.second_surname = second_surname
    client.email = @email
    client.main_phone = params.dig(:properties, :phone, :value) || "0000000000"
    client.user = @owner
    client.source = AutomatedEmail.sources[:integration]
    if client.save
      json_response(client, :created)
    else
      json_error_response(client.errors, :unprocessable_entity)
    end
  end

  private

    def find_hubspot_owner
      owner_email = params.dig(:"associated-owner", :email)&.downcase
      @owner = User.find_by email: owner_email

      if @owner.nil?
        render json: { status: :unprocessable_entity, code: 422 }, status: :unprocessable_entity
      end
    end

    def validate_client_duplicity
      @email = params.dig(:properties, :email, :value)&.downcase

      unless Client.where(email: @email).count == 0
        render json: { status: :unprocessable_entity, code: 422 }, status: :unprocessable_entity
      end
    end

    def validate_hubspot_request
      client_secret = "b01e6c8e-8301-4f3f-a496-dc23dcae587d" # Only works with huspot app id: 217081
      source_string = client_secret + request.request_method + request.original_url + request.raw_post

      hash_result = Digest::SHA256.hexdigest source_string
      hash_sent = request.headers["X-HubSpot-Signature"]

      unless hash_result == hash_sent
        render json: { status: :unprocessable_entity, code: 422 }, status: :unprocessable_entity
      end
    end
end
