# frozen_string_literal: true

# When adding a new attribute method in this class you must create its equivalent in the file "preview_concern.rb"
# which is used for the preview of emails and pdfs.
class AccountStatus < DocumentHandler
  include EntityNamesConcern
  include DateHelper
  include ActionController::MimeResponds
  include AdditionalConceptsHelper
  include InstallmentsHelper
  include FoldersHelper
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  attr_reader :params
  FILE_PATH = "installments/new_format/account_status.html.erb"

  delegate :can?, :cannot?, to: :ability

  def initialize(folder, user)
    @folder = folder
    @clients = @folder.clients
    @project = @folder.project
    @phase = @folder.phase
    @stage = @folder.stage
    @lot = @folder.lot
    @date = Time.zone.now
    @client = @folder.client
    @user = user
    @params = {}
    super(FILE_PATH, layout: "pdf")
  end

  def to_pdf(*args)
    super(*args)
  end

    private

      def load_data
        generate
        set_project_entity_names_by_folder
        set_configuration
        validate_errors
        set_default_quote
        set_additional_concept_payments
        transform_new_payment_data
        slice_payments
      end

      def locals
        {}
      end

      def assigns
        load_data

        @name = "Estado de Cuenta"
        @bank_accounts = @folder.stage.enterprise.bank_accounts

        {
          folder: @folder,
          clients: @clients,
          project: @project,
          phase: @phase,
          stage: @stage,
          lot: @lot,
          date: @date,
          client: @client,
          name: @name,
          project_singular: @project_singular,
          phase_singular: @phase_singular,
          stage_singular: @stage_singular,
          payment_total_default: @payment_total_default,
          quotation_total_payments: @quotation_total_payments,
          pending_capital_amount: @pending_capital_amount,
          capital_amount_overdue: @capital_amount_overdue,
          capital_next_overdue: @capital_next_overdue,
          clients: @clients,
          stage: @stage,
          bank_accounts: @bank_accounts,
          slice_cash_flows: @slice_cash_flows,
          slice_installments: @slice_installments,
          additional_concepts_payments: @additional_concepts_payments
        }
      end

      def ability
        @ability ||= Ability.new(@user)
      end
end
