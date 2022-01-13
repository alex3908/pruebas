# frozen_string_literal: true

class CatalogsController < ApplicationController
  authorize_resource class: false

  def index
    @roles = Role.count if can?(:read, Role)
    @enterprises = Enterprise.count if can?(:read, Enterprise)
    @branches = Branch.count if can?(:read, Branch)
    @settings = Setting.count if can?(:read, Setting)
    @payment_methods = PaymentMethod.count if can?(:read, PaymentMethod)
    @identification_types = IdentificationType.count if can?(:read, IdentificationType)
    @promotions = Promotion.count if can?(:read, Promotion)
    @evaluations = Evaluation.count if can?(:read, Evaluation)
    @signers = Signer.count if can?(:read, Signer)
    @lead_sources = LeadSource.count if can?(:read, LeadSource)
    @credit_schemes = CreditScheme.count if can?(:read, CreditScheme)
    @commission_schemes = CommissionScheme.count if can?(:read, CommissionScheme)
    @tags = Tag.count if can?(:read, Tag)
    @steps = Step.count if can?(:read, Step)
    @document_templates = DocumentTemplate.count if can?(:read, DocumentTemplate)
    @document_sections = DocumentSection.count if can?(:read, DocumentSection)
    @document_email_templates = EmailTemplate.count if can?(:read, EmailTemplate)
    @folder_user_concepts = FolderUserConcept.count if can?(:read, FolderUserConcept)
    @additional_concepts = AdditionalConcept.count if can?(:read, AdditionalConcept)
    @imports = can?(:import_amortization, Folder) || can?(:import, CashFlow) || can?(:import, ClientUser)
    @classifiers = Classifier.count if can?(:read, Classifier)
    @client_user_concepts = ClientUserConcept.count if can?(:read, ClientUserConcept)
    @frequent_questions = FrequentQuestion.count

    if can?(:read, Contract) && can?(:custom_index, Contract)
      @contracts = Contract.count
    else
      @contracts = Contract.includes(:folder).where(folders: { contract_id: nil }).count
    end
  end
end
