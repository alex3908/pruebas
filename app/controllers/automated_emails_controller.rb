# frozen_string_literal: true

class AutomatedEmailsController < ApplicationController
  load_and_authorize_resource :email_template
  load_and_authorize_resource :automated_email, through: :email_template
  before_action :set_steps, :set_folder_user_concept, :set_client_user_concept, only: [:new, :edit, :show_inputs]

  def index
  end

  def new
  end

  def edit
  end

  def create
    respond_to do |format|
      if @automated_email.save
        format.html { redirect_to email_template_automated_emails_path(@email_template), notice: "El correo automatizado fue creado correctamente." }
      else
        format.html { redirect_to email_template_automated_emails_path(@email_template), alert: @automated_email.errors.values.join(",") }
      end
    end
  end

  def update
    respond_to do |format|
      if @automated_email.update(automated_email_params)
        format.html { redirect_to email_template_automated_emails_path(@email_template), notice: "El correo automatizado fue editado correctamente." }
      else
        format.html { redirect_to email_template_automated_emails_path(@email_template), alert: @automated_email.errors.values.join(",") }
      end
    end
  end

  def destroy
    @automated_email.destroy
    respond_to do |format|
      format.html { redirect_to email_template_automated_emails_path(@email_template), notice: "La plantilla fue eliminada correctamente." }
      format.json { head :no_content }
    end
  end

  def show_inputs
    @automated_email = AutomatedEmail.new
  end

    private

      def set_steps
        @steps = Step.all
      end

      def set_folder_user_concept
        @folder_user_concepts = FolderUserConcept.all
      end

      def set_client_user_concept
        @client_user_concepts = ClientUserConcept.all
      end

      def automated_email_params
        params.require(:automated_email).permit(:step_id, :reciever_type, :execution_type, :emails, :hidden_state, :automated_type, :delivery_in, folder_user_concept_ids: [], client_user_concept_ids: [])
      end
end
