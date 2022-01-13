# frozen_string_literal: true

class DigitalSignatureServicesController < ApplicationController
  load_and_authorize_resource :enterprise
  load_resource through: :enterprise
  before_action :set_steps, :set_document_templates, only: [:edit]

  def create
    if @digital_signature_service.save
      flash[:success] = "El servicio fue inicializado correctamente, asegúrate de completar la configuración para que pueda ser usado"
      redirect_to edit_enterprise_digital_signature_service_path(@enterprise, @digital_signature_service)
    else
      flash[:error] = "No fue posible inicializar el servicio"
      redirect_to edit_enterprise_path(@enterprise)
    end
  end

  def edit
  end

  def update
    if @digital_signature_service.update(digital_signature_service_params)
      flash[:success] = "El servicio fue actualizado correctamente."
      redirect_to edit_enterprise_path(@enterprise)
    else
      flash[:error] = @digital_signature_service.errors.values.join(",")
      redirect_to edit_enterprise_path(@enterprise)
    end
  end

  def destroy
    if  @digital_signature_service.destroy
      flash[:success] = "El servicio fue eliminado correctamente."
      redirect_to edit_enterprise_path(@enterprise)
    else
      flash[:error] = "Hubo un error al eliminar el servicio"
      redirect_to edit_enterprise_path(@enterprise)
    end
  end

  def digital_signature_service_params
    params.require(:digital_signature_service).permit(:name,
                                                      :environment,
                                                      :step_id,
                                                      :enterprise_id,
                                                      :is_automatic,
                                                      :jump_to_step,
                                                      :jump_step_id,
                                                      :document_template_id,
                                                      :document_nom_id,
                                                      :use_email_confirmation,
                                                      :is_shield_level_three_clients,
                                                      :is_shield_level_three_signers,
                                                      :shield_level_three_message,
                                                      properties: {})
  end

  def set_steps
    @steps = Step.all
  end

  def set_document_templates
    @document_templates = DocumentTemplate.all
  end
end
