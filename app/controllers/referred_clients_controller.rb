# frozen_string_literal: true

class ReferredClientsController < ApplicationController
  load_and_authorize_resource :client
  load_and_authorize_resource :referred_client, through: :client

  def create
    @referred_client.save
    render :response, status: :ok
  end

  def destroy
    @referred_client.destroy
    render :response, status: :ok
  end

    private

      def referred_client_params
        params.require(:referred_client).permit(:client_id, :referred_client_id)
      end
end
