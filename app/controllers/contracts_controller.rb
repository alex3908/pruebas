# frozen_string_literal: true

class ContractsController < ApplicationController
  include ContractsHelper
  load_and_authorize_resource
  before_action :set_signers, :set_tags, only: [:new, :create, :edit, :update]
  before_action :set_non_signers, only: [:new, :create, :edit, :update]
  before_action :set_document_templates, only: [:new, :create, :edit, :update]
  helper_method :sort_column, :sort_direction

  # GET /contracts
  def index
    @per_page = params[:per_page].to_i < 1 ? 10 : params[:per_page] || 10
    if can?(:custom_index, Contract)
      @contracts = Contract.paginate(page: params[:page], per_page: @per_page).set_params(params, sort_column, sort_direction)
    else
      @contracts = Contract.includes(:folder).where(folders: { contract_id: nil }).paginate(page: params[:page], per_page: @per_page).order(id: :asc)
    end
    @filter_path = contracts_path
  end

  # GET /contracts/1
  def show
    @logs = Log.where(element: "contract", element_id: @contract.id).includes(:user) if can?(:see_binnacle, Contract)
    @per_page = params[:per_page].to_i < 1 ? 10 : params[:per_page] || 10
    @stages = Stage.paginate(page: params[:page], per_page: @per_page).includes(phase: :project).set_params(params, sort_column, sort_direction)
    @projects = Project.includes(phases: :stages).order(id: :asc)
    contract = Contract.find_by! id: params[:id]
    @filter_path = contract_path(contract)
  end

  def liquid_tags
    yaml_text = File.open("lib/liquid_tags.yml")
    hash = YAML.load(yaml_text)
    hash.shift
    @tags = HashWithIndifferentAccess.new(hash)
    render "tags/liquid_tags"
  end

  def activate
    raise CanCan::AccessDenied.new("No tienes permisos para activar/desactivar este contrato") unless can?(:update, Contract)

    @status = (params[:status] == "true")
    @stage = Stage.find_by! id: params[:stage]
    @duplicated = duplicated_contracts(@stage.contracts).any?

    if !@duplicated && @status && !@stage.has_contract(@contract)
      @stage.contracts << @contract
    elsif !@status && @stage.has_contract(@contract)
      @stage.contracts.delete(@contract)
    end


    respond_to do |format|
      if @duplicated && @status
        @message = "No puedes activar este contrato, pues esta etapa cuenta con un contrato con las mismas reglas. Contrato similar: \"#{duplicated_contracts.first.label}\" (id: #{duplicated_contracts.first.id})"
        format.html { redirect_to contract_path(@contract), notice: @message }
        format.js
        format.json { render json: @contract, status: :unprocessable_entity, location: @contract }
      elsif @stage.save
        @message = (@status) ? "Contrato activado correctamente." : "Contrato desactivado correctamente."
        format.html { redirect_to contract_path(@contract), notice: @message }
        format.js
        format.json { render json: @contract, status: :ok, location: @contract }
      else
        format.html redirect_to contract_path(@contract), notice: "Hubo un error al intentar hacer el cambio."
        format.js
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /contracts/new
  def new
    if params[:contract].present?
      raise CanCan::AccessDenied.new("No tienes permisos para crear un contrato personalizado") unless can?(:custom_create, Contract)
      contract_template = Contract.find_by(id: params[:contract])
      if contract_template.present?
        @contract = Contract.new(contract_template.attributes.merge)
        @contract.label = "#{@contract.label} (Copia)"
        @contract.signers = contract_template.signers
      end
    else
      raise CanCan::AccessDenied.new("No tienes permisos para crear un nuevo contrato") unless can?(:create, Contract)
    end
    @contract ||= Contract.new
  end

  # GET /contracts/1/edit
  def edit
    if @contract.folder.present?
      raise CanCan::AccessDenied.new("No tienes permisos para editar este contrato personalizado") unless can?(:custom_update, Contract)
    else
      raise CanCan::AccessDenied.new("No tienes permisos para editar este contrato") unless can?(:update, Contract)
    end
  end

  # POST /contracts
  def create
    raise CanCan::AccessDenied.new("No tienes permisos para crear contratos") unless can?(:custom_create, Contract) || can?(:create, Contract)
    contract_params = params.dig(:contract, :folder_id)
    if contract_params.present? && @contract.save
      @folder = Folder.find_by(id: contract_params).update(contract: @contract)
      contract_template = Contract.find_by(id: params.dig(:contract, :contract_template))
      if contract_template.present?
        contract_template.contract_annexes.order(:order).each_with_index do |annexe, index|
          @contract.contract_annexes.create(annexe_id: index, order: index, amount: annexe.amount)
        end
      end
      redirect_path(folder_path(@contract.folder), @contract)
    elsif contract_params.present?
      flash[:error] = "Hubo un error al intentar crear el contrato personalizado:" + @contract.errors.full_messages.join(",")
      render :new
    elsif @contract.save
      redirect_path(contracts_path, @contract)
    else
      flash[:error] = "Hubo un error al intentar crear una plantilla de contrato:" + @contract.errors.full_messages.join(",")
    end
  end

  # PATCH/PUT /contracts/1
  def update
    if @contract.folder.present?
      raise CanCan::AccessDenied.new("No tienes permisos para actualizar este contrato personalizado") unless can?(:custom_update, Contract)
      if @contract.update(contract_params)
        redirect_path(folder_path(@contract.folder), @contract)
      else
        flash[:error] = "Hubo un problema actualizando el contrato: " + @contract.errors.full_messages.join(",")
        render :edit
      end
    else
      raise CanCan::AccessDenied.new("No tienes permisos para actualizar este contrato") unless can?(:update, Contract)
      @contract.assign_attributes(contract_params)
      if rules_changed? && duplicated_contracts_in_same_stage.any?
        flash[:error] = "Estás intentando modificar las reglas de este contrato, pero ya existe un contrato con éstas reglas en las siguientes #{@stage_plural.downcase}: #{stages_name_with_id(duplicated_contracts_in_same_stage)}."
        render :edit
      elsif @contract.save
        redirect_path(contracts_path, @contract)
      else
        flash[:error] = "Hubo un problema actualizando el contrato: " + @contract.errors.full_messages.join(",")
        render :edit
      end
    end
  end

  # DELETE /contracts/1
  def destroy
    if @contract.folder.present?
      raise CanCan::AccessDenied.new("No tienes permisos para eliminar este contrato personalizado") unless can?(:custom_destroy, Contract)
      if @contract.folder.update(contract: nil) && @contract.destroy
        message = { success: "Contrato personalizado eliminado correctamente." }
      else
        message = { error: "Hubo un error al intentar eliminar el contrato personalizado" }
      end
    else
      raise CanCan::AccessDenied.new("No tienes permisos para eliminar este contrato") unless can?(:destroy, Contract)
      if @contract.destroy
        message = { success: "Contrato eliminado correctamente." }
      else
        message = { error: "Hubo un error al intentar eliminar el contrato" }
      end
    end
    redirect_to contracts_path, flash: message
  end

  def preview
    purchase_promise = @contract.render_preview

    respond_to do |format|
      format.html { render html: purchase_promise.render_to_string } unless Rails.env.production?
      format.pdf do
        send_data purchase_promise.to_pdf(:with_page_number, :with_margin), filename: "purchase_promise.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def restore_annexe_order
    if @contract.contract_annexes.destroy_all
      ContractAnnexe::ANNEXES_NAMES.each_with_index do |annexe, index|
        @contract.contract_annexes.create(annexe_id: index, order: index)
      end
    end
    redirect_to edit_contract_path(@contract)
  end

  def update_custom_annexe_amount
    return unless params[:annexe_amount].present? && params[:contract_annexe_id].present?
    contract_annexe = ContractAnnexe.find(params[:contract_annexe_id])
    contract_annexe.update(amount: params[:annexe_amount]) if contract_annexe.present?
  end

  def remove_file
    contract = Contract.find(params[:contract_id])
    attachment = ActiveStorage::Attachment.find(params[:file_id])
    attachment.purge
    redirect_to edit_contract_path(contract), flash: { success: "Se elimino correctamente el archivo." }
  rescue StandardError
    redirect_to edit_contract_path(contract), flash: { error: "No se pudo eliminar el archivo." }
  end

  private

    def redirect_path(close_path, contract)
      if params[:save_action] == "save_and_continue"
        redirect_to edit_contract_path(contract), success: "Contrato guardado correctamente."
      else
        redirect_to close_path, success: "Contrato guardado correctamente."
      end
    end

    def contract_params
      params.require(:contract).permit(:key,
                                      :data_type,
                                      :label,
                                      :value,
                                      :footer,
                                      :buyer_definition,
                                      :coowner_1_definition,
                                      :coowner_2_definition,
                                      :coowner_3_definition,
                                      :coowner_4_definition,
                                      :coowner_5_definition,
                                      :max_amount,
                                      :min_amount,
                                      :max_metrics,
                                      :min_metrics,
                                      :client_gender,
                                      :max_owners,
                                      :lot_type,
                                      :client_nationality,
                                      :periods_amount,
                                      :client_type,
                                      :financing_type,
                                      :paginated,
                                      :differed_downpayment,
                                      :fit_signature,
                                      :two_columns,
                                      signer_ids: [],
                                      annexes: [],
                                      non_signer_ids: [],
                                      document_template_ids: [],
                                      contract_client_document_ids: [])
    end

    def folder_params
      params.require(:contract).permit(:folder_id)
    end

    def set_signers
      @signers = Signer.where(is_an_observer: false)
    end

    def set_non_signers
      @non_signers = Signer.observers
    end

    def set_document_templates
      @folders_documents = DocumentTemplate.for_folders
      @client_documents = DocumentTemplate.for_clients
    end

    def duplicated_contracts(contracts = Contract.all)
      contracts = contracts.where(min_amount: @contract.min_amount,
                                          min_metrics: @contract.min_metrics, lot_type: @contract.lot_type,
                                          client_type: @contract.client_type, financing_type: @contract.financing_type,
                                          max_owners: @contract.max_owners, client_nationality: @contract.client_nationality)
      contracts = contracts.where(max_amount: @contract.max_amount) if @contract.max_metrics.present?
      contracts = contracts.where(max_metrics: @contract.max_metrics) if @contract.max_metrics.present?
      contracts = contracts.where(client_gender: @contract.client_gender) if @contract.client_gender.present?
      contracts = contracts.where(periods_amount: @contract.periods_amount) if @contract.periods_amount.present?
      contracts = contracts.where(differed_downpayment: @contract.differed_downpayment) if @contract.differed_downpayment.present?
      contracts = contracts.includes(:folder).where(folders: { contract_id: nil })
      contracts
    end

    def rules_changed?
      @contract.min_amount_changed? || @contract.min_metrics_changed? || @contract.lot_type_changed? || @contract.client_type_changed? || @contract.financing_type_changed? || @contract.max_owners_changed? || @contract.client_nationality_changed?
    end

    def duplicated_contracts_in_same_stage
      contract_stages = @contract.stages.select(:name, :id)
      common_stages = duplicated_contracts.map { |contract| contract.stages.select(:name, :id) }
      common_stages = common_stages.flatten
      contract_stages & common_stages
    end

    def stages_name_with_id(stages)
      stages_names = stages.map.with_index { |s| "#{s.name} (#{s.id})" }
      stages_names.join(", ")
    end

    def set_tags
      @tags = Tag.where(active: true, related_to: ["contracts", "all"]).order(id: :ASC)
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def sort_column
      if request.path == contracts_path
        if Contract.column_names.include?(params[:sort])
          return "label" if params[:sort] == "label"
        else
          "contracts.id"
        end
      else
        if Stage.column_names.include?(params[:sort]) || ["project_id", "phase_id", "stage_id"].include?(params[:sort])
          return "projects.name" if params[:sort] == "project_id"
          return "phases.name" if params[:sort] == "phase_id"
          return "stages.name" if params[:sort] == "stage_id"
          params[:sort]
        else
          "stages.created_at"
        end
      end
    end
end
