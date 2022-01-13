# frozen_string_literal: true

class CommissionSchemesController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: :edit
  before_action :data_for_form

  def index
  end

  def new
  end

  def create
    if @commission_scheme.save
      redirect_to commission_schemes_path, success: I18n.t("controller.messages.created", model: CommissionScheme.model_name.human)
    else
      render :new
    end
  end

  def edit
    @commission_scheme = CommissionScheme.includes(commission_schemes_roles: [:role]).find(params[:id])
  end

  def update
    if @commission_scheme.update(commission_scheme_params)
      redirect_to commission_schemes_path, success: I18n.t("controller.messages.updated", model: CommissionScheme.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    if @commission_scheme.destroy
      redirect_to commission_schemes_path, success: I18n.t("controller.messages.destroyed", model: CommissionScheme.model_name.human)
    else
      flash[:error] = @commission_scheme.errors.full_messages.join(". ")
      redirect_to commission_schemes_path
    end
  end

  private

    def commission_scheme_params
      params.require(:commission_scheme).permit(:name,
                                                :global_commission,
                                                commission_schemes_roles_attributes: commission_schemes_roles_params)
    end

    def commission_schemes_roles_params
      [
        :id,
        :role_id,
        :folder_user_concept_id,
        :commission,
        :_destroy
      ]
    end

    def data_for_form
      @roles_evo = Role.where(is_evo: true)
      @roles_no_evo = Role.where(is_evo: false)
      @folder_user_concepts = FolderUserConcept.all
    end
end
