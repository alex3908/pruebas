# frozen_string_literal: true

class Contract < ApplicationRecord
  has_one :folder

  has_many :contract_signers
  has_many :stage_contracts, dependent: :destroy
  has_many :stages, through: :stage_contracts
  has_many :signers, through: :contract_signers, dependent: :delete_all
  has_many :contract_document_templates, dependent: :destroy
  has_many :document_templates, through: :contract_document_templates, dependent: :delete_all
  has_many :contract_client_documents, dependent: :destroy # TODO: This relation might have already been deprecated see task contract_client_documents.rake
  has_many :contract_annexes, dependent: :destroy
  has_many :contract_non_signers
  has_many :non_signers, through: :contract_non_signers, dependent: :delete_all

  accepts_nested_attributes_for :contract_annexes

  has_many_attached :annexes

  CLIENT_GENDER = { Masculino: "male", Femenino: "female" }
  LOT_TYPE = { Residencial: "residential", Comercial: "commercial" }
  CLIENT_NATIONALITY = { Nacional: "national", Extranjero: "foreign" }
  CLIENT_TYPE = { 'Persona moral': "moral", 'Persona física': "physical" }
  FINANCING_TYPE = { 'De contado': "cash", Financiado: "financed" }
  DIFFERED_DOWNPAYMENT = { 'De contado': "downpayment_cash", Financiado: "downpayment_financed" }

  enum client_gender: { male: 0, female: 1 }
  enum lot_type: { residential: 0, commercial: 1 }
  enum client_nationality: { national: 0, foreign: 1 }
  enum client_type: { moral: 0, physical: 1 }
  enum financing_type: { cash: 0, financed: 1 }
  enum differed_downpayment: { downpayment_cash: 0, downpayment_financed: 1 }

  after_create :create_annexes_order, unless: :has_contract_annexes?
  after_update :binnacle
  after_touch :create_annexes_order, unless: :has_contract_annexes?
  validate :validate_liquid_format

  def self.set_params(params, sort_column, sort_direction)
    order(sort_column + " " + sort_direction).search(params)
  end

  def self.search(params)
    contracts = params[:type] == "Personalizado" ? Contract.includes(:folder).where.not(folders: { contract_id: nil }) : Contract.includes(:folder).where(folders: { contract_id: nil })
    contracts = contracts.where("LOWER(label) LIKE LOWER(?)", "%#{params[:label].tr(" ", "%")}%") if params[:label].present?
    contracts
  end

  def self.by_rules(rules, stage_id)
    contract = all.joins(:stage_contracts).where("stage_id = ? AND lot_type = ?
    AND client_type = ? AND financing_type = ?
    AND max_owners >= ? AND client_nationality = ?",
    stage_id, rules.lot_type,
    rules.client_type, rules.financing_type,
    rules.clients, rules.client_nationality)
    contract = contract.where("min_amount <= ? OR min_amount IS NULL", rules.total)
    contract = contract.where("max_amount >= ? OR max_amount IS NULL", rules.total)
    contract = contract.where("min_metrics <= ? OR min_metrics IS NULL", rules.area)
    contract = contract.where("max_metrics >= ? OR max_metrics IS NULL", rules.area)
    contract = contract.where("client_gender = ? OR client_gender IS NULL", rules.client_gender)
    contract = contract.where("periods_amount = ? OR periods_amount IS NULL", rules.periods_amount)
    contract = contract.where("differed_downpayment = ? OR differed_downpayment IS NULL", rules.differed_downpayment)
    contract = contract.includes(:folder).where(folders: { contract_id: nil })
    contract = contract.order(max_owners: :asc)
    contract.first
  end

  def template
    Liquid::Template.parse(value)
  end

  def footer_template
    Liquid::Template.parse(footer)
  end

  def validate_liquid_format
    Liquid::Template.parse(value)
  rescue Liquid::SyntaxError
    errors.add(:value, "El formato del contrato es incorrecto, revisa tus variables.")
  end

  def render_preview
    PurchasePromisePreview.new(self)
  end

  def data_type_label
    data_types = {
      "integer" => "Entero",
      "percentage" => "Porcentaje",
      "html" => "Texto",
    }

    data_types[self.data_type]
  end

  def binnacle
    unless Current.user.nil?
      Log.create({
        date: Time.zone.now,
        element_changes: nil,
        element: "contract",
        element_id: self.id,
        user_id: Current.user.id
      })
    end
  end

private
  def create_annexes_order
    ContractAnnexe::ANNEXES_NAMES.each_with_index do |annexe, index|
      self.contract_annexes.create(annexe_id: index, order: index)
    end
  end

  def has_contract_annexes?
    self.contract_annexes.any?
  end
end
