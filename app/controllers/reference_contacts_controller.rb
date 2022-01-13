# frozen_string_literal: true

class ReferenceContactsController < ApplicationController
  load_and_authorize_resource :reference_contact

  before_action :search_reference_contacts, only: [:show]

  def index
  end

  def create
    @reference_contact.save
    render :response, status: :ok
  end


  def references_show
    render :index, status: :ok
  end

  def update
    @reference_contact.update(reference_contact_params)
    render :response, status: :ok
  end

  def show; end

  def destroy
    @reference_contact.destroy
    render :response, status: :ok
  end

  private

    def search_reference_contacts
      @contacts = Client.joins(:reference_contacts).select(
        "clients.name, clients.id as client_id, reference_contacts.id as contact_id,
        reference_contacts.name as contact_name,
        reference_contacts.email as contact_email,
        reference_contacts.concept as contact_concept,
        reference_contacts.phone as contact_phone
      ").where(reference_contacts: { id: params[:id] })
      render json: @contacts, status: :ok
    end

    def reference_contact_params
      params.require(:reference_contact).permit(:name, :email, :phone, :concept, :client_id)
    end
end
