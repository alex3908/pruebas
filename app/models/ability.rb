# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :index, to: :crud

    # Define abilities for the passed in user here. For example:
    user ||= User.new # guest user (not logged in)
    user = User.includes(role: :permissions).find(user.id) if user.persisted?

    if user.persisted? && user.role.present?
      permissions = user.role.permissions
      permissions.each { |p| can p.action_sym, p.subject_sym }

      can :exit, User
      can :read, JobStatus
      can :read, ReferenceContact
      can :create, TinyUpload
      can :read, Installment
      can :submit_documentation, User
      can :edit_documentation, User
      can :users, FolderUserConcept
      can :new_payment, Installment
      can :new_restructure, Installment
      can :toggle_invoice, Folder
      can :reassign_client, Folder
      can :reassign_seller, Folder
      can :remove_file, User
      can :custom_installments, Installment
      can :process_custom_installments, Installment
      can :create_custom_installments, Installment
      can :show_inputs, AutomatedEmail
      can :read, Client if can?(:see_all, Client)
      can :get_leaders, User if can?(:create, User) || can?(:update, User)
      can :assignment_stage, User if can?(:assignment, User)
      can :assign_all, User if can?(:assignment, User)
      can :deallocate_all, User if can?(:assignment, User)
      can :resend_invitation, User if can?(:update, User)
      can :reset_password, User if can?(:update, User)
      can :evo_access, User if user.role.is_evo || user.role?("salesman")
      can :verify_reserve_status, Role if can?(:create, User) || can?(:update, User)
      can :preview, Contract if can?(:update, Contract)
      can :restore_annexe_order, Contract if can?(:update, Contract)
      can :update_custom_annexe_amount, Contract if can?(:update, Contract)
      can :remove_file, Contract if can?(:update, Contract)
      can :remove_file, Project if can?(:update, Project)
      can :level_price, Project if can?(:update, Project)
      can :seller, Folder if can?(:reserve, :quote)
      can :add_client, Folder if can?(:change_buyer, Folder)
      can :remove_client, Folder if can?(:change_buyer, Folder)
      can :update_files, Client if can?(:update, Client)
      can :read, Folder if can?(:see_all, Folder)
      can :import, Lot if can?(:create, Lot)
      can :download, Lot if can?(:import, Lot)
      can :export, Lot if can?(:import, Lot)
      can :deallocate_lot, BlueprintLot if can?(:update, Lot)
      can :update, BlueprintLot if can?(:update, Lot)
      can :deallocate, Lot if can?(:update, BlueprintLot)
      can :invoice, Installment if can?(:create, Installment)
      # TODO: The read action in Payment permissions doesnt exist
      can :invoice, Payment if can?(:read, CashFlow)
      can :remove_file, Commission if can?(:update, Commission)
      can :deallocate, Blueprint if can?(:update, Lot)
      can :change_status, Branch if can?(:update, Branch)
      can :change_status, BankAccount if can?(:update, BankAccount)
      can :validate_email_json, Client if can?(:create, Client) || can?(:update, Client)
      can :change_status, Evaluation if can?(:update, Evaluation)
      can :recovery, User if can?(:create, User)
      can :reject_file, User if can?(:verify_user_file, User)
      can :approve_file, User if can?(:verify_user_file, User)
      can :validate_user, User if can?(:verify_user_file, User)
      can :read, :catalog if can?(:read, PaymentMethod) ||
          can?(:read, Branch) || can?(:read, Enterprise) ||
          can?(:read, Setting) || can?(:read, Role) || can?(:read, Signer) ||
          can?(:read, Contract) || can?(:read, Promotion) ||
          can?(:read, Step)
      can :create, BankAccount if can?(:reserve, :quote)
      can :update, BankAccount if can?(:reserve, :quote)
      can :destroy, BankAccount if can?(:reserve, :quote)
      can :imports, Stage if can?(:import_corrections, Stage) || can?(:import_charges, Stage)
      can :download_corrections, Stage if can?(:import_corrections, Stage)
      can :download_charges, Stage if can?(:import_charges, Stage)
      can :status, Stage if can?(:force_activate, Stage)
      can :destroy, Role if can?(:create, Role)
      can :update, BlueprintStage if can?(:update, Stage)
      can :deallocate, Stage if can?(:update, Stage)
      can :show_stage_commission_schemes_roles, Stage if can?(:create, Stage) || can?(:update, Stage)
      can :annexes, Lot if can?(:update, Lot)
      can :annexe_1, Lot if can?(:annexes, Lot)
      can :annexe_2, Lot if can?(:annexes, Lot)
      can :annexe_3, Lot if can?(:annexes, Lot)
      can :invoice, CashFlow if can?(:invoice, Payment)
      can :read, FileApproval if can?(:verify, DocumentTemplate) || can?(:verify_user_file, User)
      can :rejectable_file, Folder if can?(:verify, DocumentTemplate) || can?(:verify_user_file, User)
      can :export, Commission if can?(:update, Commission)
      can :download, Commission if can?(:read, Commission)
      can :show_pipeline, Step if can?(:read, Folder)
      can :step_folders, Step if can?(:read, Folder)
      can :see_payment_modal, Folder if can?(:read, Folder)
      can :send_email_payment_link, Folder if can?(:read, Folder)
      can :see_preview_modal, EmailTemplate if can?(:create, EmailTemplate) || can?(:update, EmailTemplate)
      can :send_preview_template, EmailTemplate if can?(:create, EmailTemplate) || can?(:update, EmailTemplate)
      can :read, AutomatedEmail if can?(:create, EmailTemplate) || can?(:update, EmailTemplate)
      can :create, AutomatedEmail if can?(:create, EmailTemplate) || can?(:update, EmailTemplate)
      can :update, AutomatedEmail if can?(:create, EmailTemplate) || can?(:update, EmailTemplate)
      can :destroy, AutomatedEmail if can?(:create, EmailTemplate) || can?(:update, EmailTemplate)
      can :export_historic, Step if can?(:step, :report)
      can :export_average_times, Step if can?(:step, :report)
      can :export_elapsed_times_per_folder, Step if can?(:step, :report)
      can :future_cash_flow_request, :report if can?(:future_cash_flow, :report)
      can :payments_request, :report if can?(:payments, :report)
      can :remove_file, Stage if can?(:update, Stage)
      can :remove_file, Lot if can?(:update, Lot)
      can :toggle_block, Step if can?(:block, Step)
      can :create, CashFlow if can?(:create, Installment)
      can :activate, AdditionalConcept if can?(:change_status, AdditionalConcept)
      can :referrals, User if can?(:read, :referent)
      can :folders, User if can?(:referrals, User)
      can :read, :sale if can?(:read, Commission) || can?(:read, Structure) || can?(:referrals, User)
      can :stages, CreditScheme if can?(:read, CreditScheme)
      can :period_max_order, CreditScheme if can?(:create, CreditScheme) || can?(:read, CreditScheme) || can?(:update, CreditScheme)
      can :liquid_tags, EmailTemplate if can?(:read, EmailTemplate)
      can :download, Commission if can?(:read, Commission)
      can :see_cancel_modal, Payment if can?(:cancel, CashFlow)
      can :see_cancel_modal, CashFlow if can?(:cancel, CashFlow)
      can :show, Structure if  can?(:read, Structure)
      can :information, Structure if can?(:see_binnacle, User)
      can :prospects, Structure if can?(:hire_and_fire, Structure)
      can :fire, Structure if can?(:hire_and_fire, Structure)
      can :hire, Structure if can?(:hire_and_fire, Structure)
      can :unaffiliated_users, Structure if can?(:affiliated_user, Structure)
      can :approve, Structure if can?(:approval, Structure)
      can :reject, Structure if can?(:approval, Structure)
      can :new_user, Structure if can?(:create_user, Structure)
      can :level_settings, Structure if can?(:set_level_to_role, Structure)
      can :role_level, Structure if can?(:set_level_to_role, Structure)
      can :replace_role, Structure if can?(:set_level_to_role, Structure)
      can :add_child_node, Structure if can?(:set_level_to_role, Structure)
      can :set_child_node, Structure if can?(:set_level_to_role, Structure)
      can :change_role, Structure if can?(:set_level_to_role, Structure)
      can :update_level_configurations, Structure if can?(:see_level_configurations_modal, Structure)
      can :see_configuration, Structure if can?(:see_level_configurations_modal, Structure)
      can :update_configuration, Structure if can?(:see_level_configurations_modal, Structure)
      can :see_structure_tree, Structure if  can?(:read, Structure)
      can :update_level, Structure if  can?(:see_level_configurations_modal, Structure)
      can :autocomplete, User if can?(:reassign_seller, Folder) || can?(:mass_reassign, Client) || can?(:read, Client)
      can :autocomplete, Client if can?(:change_buyer, Folder) || can?(:reassign_client, Folder) || can?(:autocomplete, ReferredClient)
      can :autocomplete_by_email, Client if can?(:create, ReferredClient)
      can :liquid_tags, Contract if can?(:read, Contract) || can?(:read, EmailTemplate)
      can :activate, Contract if can?(:update, Contract)
      can :blueprint, Stage if can?(:read, Stage)
      can :annexe, Stage if can?(:read, Stage)
      can :blueprint, Lot if can?(:read, Lot)
      can :annexe, Lot if can?(:read, Lot)
      can :map_annexe, Lot if can?(:read, Lot)
      can :payment_settings, Installment if can?(:read, Folder)
      can :payment_tabs_settings, Installment if can?(:read, Folder)
      can :invite_update, Subscription if can?(:update, Subscription)
      can :resend_email_confirmation, Client if can?(:read, Client)
      can :payment_modal_info, Folder if can?(:read, Folder)
      can :classifiers, Role if can?(:read, Classifier)
      can :get_concepts, ClientUserConcept if can?(:read, Client) || can?(:read, Folder)
      can :list_users_role, ClientUser if can?(:create, ClientUser) || can?(:update, ClientUser)
      can :get_referred_clients, Client if can?(:create, Client) || can?(:update, Client)
      can :sign_links_modal_info, Folder if can?(:read, Folder)
      can :send_sign_link_email, Folder if can?(:read, Folder)
      can :remove_file, EmailTemplate if can?(:edit, EmailTemplate)
      can :read, Payment if can?(:read, CashFlow)
      can :cancel, Payment if can?(:cancel, CashFlow)
      can :resend_notification, Payment if can?(:resend_notification, CashFlow)
      can :attributes_to_change, Promotion if can?(:read, Promotion)
      can :recovery_password, UserClient if can?(:create, UserClient)

      can :create, Contract if can?(:custom_create, Contract)
      can :read, Contract if can?(:custom_index, Contract)
      can :update, Contract if can?(:custom_update, Contract)
      can :destroy, Contract if can?(:custom_destroy, Contract)

      # Reports

      can :read, :report if can?(:payments, :report) ||
        can?(:additional_concept_payments, :report) ||
        can?(:overdue_balances, :report) ||
        can?(:step, :report) ||
        can?(:file_approvals, :report) ||
        can?(:balances_close_to_due, :report) ||
        can?(:commissions, :report) ||
        can?(:folder_users, :report) ||
        can?(:future_cash_flow, :report) ||
        can?(:online_payment_tickets, :report) ||
        can?(:units, :report) ||
        can?(:delays, :report) ||
        can?(:commision_dispersion, :report) ||
        can?(:folders, :report) ||
        can?(:clients, :report) ||
        can?(:quote_logs, :report) ||
        can?(:users_kpi, :report) ||
        can?(:referred_clients, :report) ||
        can?(:users, :report) ||
        can?(:referred_users, :report)

      can :users_kpi_request, :report if can?(:users_kpi, :report)
      can :quote_logs_request, :report if can?(:quote_logs, :report)
      can :referred_clients_request, :report if can?(:referred_clients, :report)
      can :users_request, :report if can?(:users, :report)
      can :referred_users_request, :report if can?(:referred_users, :report)
      can :export, AdditionalConceptPayment if can?(:additional_concept_payments, :report)
      can :online_payment_tickets_request, :report if can?(:online_payment_tickets, :report)
      can :clients_request, :report if can?(:clients, :report)
      can :export_units, Project if can?(:units, :report)
      can :export, Folder if can?(:folders, :report) || can?(:report, Folder)
      can :export, Payment if  can?(:payments, :report)
      can :delays, Payment if  can?(:payments, :report)
      can :export_overdue_balances, Folder if can?(:overdue_balances, :report)
      can :export, FileApproval if can?(:file_approvals, :report)
      can :export_balances_close_to_due, Folder if can?(:balances_close_to_due, :report)
      can :export_xlsx, Commission if can?(:commissions, :report)
      can :export_dispersion, Commission if can?(:commision_dispersion, :report)
      can :sales_request, :report if can?(:sales, :report)
      # / Reports


    end
  end
end
