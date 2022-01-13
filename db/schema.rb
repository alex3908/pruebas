# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_12_002222) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :serial, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "additional_concept_payments", force: :cascade do |t|
    t.bigint "cash_flow_id"
    t.bigint "additional_concept_id"
    t.string "amount_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "enterprise_id"
    t.index ["additional_concept_id"], name: "index_additional_concept_payments_on_additional_concept_id"
    t.index ["cash_flow_id"], name: "index_additional_concept_payments_on_cash_flow_id"
    t.index ["enterprise_id"], name: "index_additional_concept_payments_on_enterprise_id"
  end

  create_table "additional_concepts", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "amount_type", default: 0
    t.decimal "amount"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "enterprise_id"
    t.index ["enterprise_id"], name: "index_additional_concepts_on_enterprise_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.string "addressable_type"
    t.bigint "addressable_id"
    t.string "country"
    t.string "postal_code"
    t.string "state"
    t.string "city"
    t.string "colony"
    t.string "location"
    t.string "street"
    t.string "house_number"
    t.string "interior_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id"
  end

  create_table "announcements", force: :cascade do |t|
    t.string "title"
    t.string "body"
    t.datetime "show_at"
    t.datetime "expire_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "api_keys", id: :serial, force: :cascade do |t|
    t.string "private_key", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "public_key"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "automated_email_client_concepts", force: :cascade do |t|
    t.bigint "automated_email_id"
    t.bigint "client_user_concept_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["automated_email_id"], name: "index_automated_email_client_concepts_on_automated_email_id"
    t.index ["client_user_concept_id"], name: "index_automated_email_client_concepts_on_client_user_concept_id"
  end

  create_table "automated_email_user_concepts", force: :cascade do |t|
    t.bigint "automated_email_id"
    t.bigint "folder_user_concept_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["automated_email_id"], name: "index_automated_email_user_concepts_on_automated_email_id"
    t.index ["folder_user_concept_id"], name: "index_automated_email_user_concepts_on_folder_user_concept_id"
  end

  create_table "automated_emails", force: :cascade do |t|
    t.bigint "step_id"
    t.bigint "email_template_id"
    t.string "reciever_type"
    t.string "execution_type"
    t.string "emails_information", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "folder_user_concept_id"
    t.string "hidden_state"
    t.string "automated_type"
    t.integer "delivery_in", default: 0
    t.index ["email_template_id"], name: "index_automated_emails_on_email_template_id"
    t.index ["folder_user_concept_id"], name: "index_automated_emails_on_folder_user_concept_id"
    t.index ["step_id"], name: "index_automated_emails_on_step_id"
  end

  create_table "bank_accounts", id: :serial, force: :cascade do |t|
    t.string "holder"
    t.string "bank"
    t.string "account_number"
    t.string "currency"
    t.string "clabe"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.string "payable_type"
    t.bigint "payable_id"
    t.boolean "principal", default: false
    t.index ["payable_type", "payable_id"], name: "index_bank_accounts_on_payable_type_and_payable_id"
  end

  create_table "blueprint_lots", id: :serial, force: :cascade do |t|
    t.string "html_type"
    t.string "html_class"
    t.string "points"
    t.string "x"
    t.string "y"
    t.string "width"
    t.string "height"
    t.string "transform"
    t.bigint "blueprint_id"
    t.bigint "lot_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "d"
    t.index ["blueprint_id"], name: "index_blueprint_lots_on_blueprint_id"
    t.index ["lot_id"], name: "index_blueprint_lots_on_lot_id"
  end

  create_table "blueprint_stages", force: :cascade do |t|
    t.string "html_type"
    t.string "html_class"
    t.string "points"
    t.string "x"
    t.string "y"
    t.string "width"
    t.string "height"
    t.string "transform"
    t.string "d"
    t.bigint "blueprint_id"
    t.bigint "stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blueprint_id"], name: "index_blueprint_stages_on_blueprint_id"
    t.index ["stage_id"], name: "index_blueprint_stages_on_stage_id"
  end

  create_table "blueprints", id: :serial, force: :cascade do |t|
    t.string "available_color"
    t.string "reserved_color"
    t.string "sold_color"
    t.string "styles"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "view_box"
    t.string "style"
    t.string "locked_color"
    t.string "level_type"
    t.bigint "level_id"
    t.index ["level_type", "level_id"], name: "index_blueprints_on_level_type_and_level_id"
  end

  create_table "branches", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
  end

  create_table "cash_back_flows", force: :cascade do |t|
    t.bigint "cash_back_id"
    t.bigint "cash_flow_id"
    t.decimal "amount_used"
    t.decimal "balance_after"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cash_back_id"], name: "index_cash_back_flows_on_cash_back_id"
    t.index ["cash_flow_id"], name: "index_cash_back_flows_on_cash_flow_id"
  end

  create_table "cash_backs", force: :cascade do |t|
    t.bigint "client_id"
    t.bigint "user_id"
    t.decimal "amount"
    t.string "status", null: false
    t.string "canceled_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "exclusive_folder_id"
    t.datetime "canceled_at"
    t.bigint "payment_method_id"
    t.index ["client_id"], name: "index_cash_backs_on_client_id"
    t.index ["exclusive_folder_id"], name: "index_cash_backs_on_exclusive_folder_id"
    t.index ["payment_method_id"], name: "index_cash_backs_on_payment_method_id"
    t.index ["user_id"], name: "index_cash_backs_on_user_id"
  end

  create_table "cash_flows", force: :cascade do |t|
    t.bigint "folder_id"
    t.bigint "client_id"
    t.bigint "branch_id"
    t.bigint "user_id"
    t.bigint "payment_method_id"
    t.bigint "bank_account_id"
    t.date "date", default: -> { "CURRENT_DATE" }, null: false
    t.decimal "amount"
    t.string "status", null: false
    t.string "canceled_by"
    t.string "charge_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "cash_back", default: false
    t.datetime "cancellation_date"
    t.string "cancelation_description"
    t.index ["bank_account_id"], name: "index_cash_flows_on_bank_account_id"
    t.index ["branch_id"], name: "index_cash_flows_on_branch_id"
    t.index ["client_id"], name: "index_cash_flows_on_client_id"
    t.index ["folder_id"], name: "index_cash_flows_on_folder_id"
    t.index ["payment_method_id"], name: "index_cash_flows_on_payment_method_id"
    t.index ["user_id"], name: "index_cash_flows_on_user_id"
  end

  create_table "classifier_roles", force: :cascade do |t|
    t.bigint "classifier_id"
    t.bigint "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classifier_id"], name: "index_classifier_roles_on_classifier_id"
    t.index ["role_id"], name: "index_classifier_roles_on_role_id"
  end

  create_table "classifier_users", force: :cascade do |t|
    t.bigint "classifier_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classifier_id"], name: "index_classifier_users_on_classifier_id"
  end

  create_table "classifiers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "classifiers_roles", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "classifier_id"
    t.index ["classifier_id"], name: "index_classifiers_roles_on_classifier_id"
    t.index ["role_id"], name: "index_classifiers_roles_on_role_id"
  end

  create_table "classifiers_users", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "classifier_id"
    t.index ["classifier_id"], name: "index_classifiers_users_on_classifier_id"
    t.index ["user_id"], name: "index_classifiers_users_on_user_id"
  end

  create_table "client_user_concepts", force: :cascade do |t|
    t.string "name"
    t.string "key", default: "custom"
    t.integer "max_users"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "role_id"
    t.index ["role_id"], name: "index_client_user_concepts_on_role_id"
  end

  create_table "client_users", force: :cascade do |t|
    t.bigint "client_id"
    t.integer "user_id"
    t.bigint "client_user_concept_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_client_users_on_client_id"
    t.index ["client_user_concept_id"], name: "index_client_users_on_client_user_concept_id"
  end

  create_table "clients", id: :serial, force: :cascade do |t|
    t.string "rid"
    t.string "name"
    t.string "first_surname"
    t.string "second_surname"
    t.string "main_phone"
    t.string "optional_phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "person", default: "physical"
    t.string "gender"
    t.integer "origin"
    t.string "branch"
    t.bigint "lead_source_id"
    t.string "online_id"
    t.boolean "confirmed_email", default: false
    t.index ["email"], name: "index_clients_on_email", unique: true
    t.index ["lead_source_id"], name: "index_clients_on_lead_source_id"
  end

  create_table "clients_logs", force: :cascade do |t|
    t.string "action"
    t.integer "client_id"
    t.integer "client_user_concept_id"
    t.integer "client_users_id"
    t.datetime "moved_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "message"
    t.bigint "folder_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["folder_id"], name: "index_comments_on_folder_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "commission_schemes", force: :cascade do |t|
    t.string "name"
    t.decimal "global_commission"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "commission_schemes_roles", force: :cascade do |t|
    t.bigint "commission_scheme_id"
    t.bigint "role_id"
    t.bigint "folder_user_concept_id"
    t.decimal "commission"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commission_scheme_id"], name: "index_commission_schemes_roles_on_commission_scheme_id"
    t.index ["folder_user_concept_id"], name: "index_commission_schemes_roles_on_folder_user_concept_id"
    t.index ["role_id"], name: "index_commission_schemes_roles_on_role_id"
  end

  create_table "commissions", id: :serial, force: :cascade do |t|
    t.bigint "folder_user_id"
    t.decimal "amount"
    t.boolean "paid", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "installment_id"
    t.bigint "payment_method_id"
    t.string "status"
    t.date "date"
    t.date "date_payment_receipt"
    t.bigint "payment_id"
    t.index ["folder_user_id"], name: "index_commissions_on_folder_user_id"
    t.index ["installment_id"], name: "index_commissions_on_installment_id"
    t.index ["payment_id"], name: "index_commissions_on_payment_id"
    t.index ["payment_method_id"], name: "index_commissions_on_payment_method_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "primary_color", default: "#1B0D40"
    t.text "custom_css"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "database"
  end

  create_table "contract_annexes", force: :cascade do |t|
    t.bigint "contract_id"
    t.integer "annexe_id", null: false
    t.integer "order", null: false
    t.integer "amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_contract_annexes_on_contract_id"
  end

  create_table "contract_client_documents", force: :cascade do |t|
    t.bigint "contract_id"
    t.integer "client_document_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_contract_client_documents_on_contract_id"
  end

  create_table "contract_document_templates", force: :cascade do |t|
    t.bigint "contract_id"
    t.bigint "document_template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_contract_document_templates_on_contract_id"
    t.index ["document_template_id"], name: "index_contract_document_templates_on_document_template_id"
  end

  create_table "contract_non_signers", force: :cascade do |t|
    t.bigint "contract_id"
    t.integer "non_signer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_contract_non_signers_on_contract_id"
    t.index ["non_signer_id"], name: "index_contract_non_signers_on_non_signer_id"
  end

  create_table "contract_signers", id: :serial, force: :cascade do |t|
    t.bigint "contract_id"
    t.bigint "signer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_contract_signers_on_contract_id"
    t.index ["signer_id"], name: "index_contract_signers_on_signer_id"
  end

  create_table "contracts", id: :serial, force: :cascade do |t|
    t.string "key"
    t.string "data_type", default: "html"
    t.string "label"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "buyer_definition"
    t.string "coowner_1_definition"
    t.string "coowner_2_definition"
    t.string "coowner_3_definition"
    t.string "coowner_4_definition"
    t.string "coowner_5_definition"
    t.integer "max_amount"
    t.integer "min_amount", default: 0
    t.integer "max_metrics"
    t.integer "min_metrics", default: 0
    t.integer "client_gender"
    t.integer "max_owners"
    t.integer "lot_type"
    t.integer "client_nationality"
    t.integer "periods_amount"
    t.integer "client_type"
    t.integer "financing_type"
    t.integer "differed_downpayment"
    t.boolean "paginated", default: false
    t.boolean "fit_signature", default: false
    t.boolean "active_annexe_pld", default: false
    t.boolean "active_amortization_table", default: false
    t.boolean "active_purchase_conditions", default: true
    t.boolean "two_columns", default: false
    t.text "footer"
  end

  create_table "coupons", force: :cascade do |t|
    t.bigint "promotion_id"
    t.string "promotion_code"
    t.boolean "draft", default: true
    t.string "status"
    t.integer "usage_limit"
    t.integer "usages", default: 0
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["promotion_id"], name: "index_coupons_on_promotion_id"
  end

  create_table "credit_schemes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "compound_interest", default: true
    t.boolean "expire_months", default: true
    t.integer "first_payment", default: 0
    t.decimal "lock_payment", default: "0.0"
    t.decimal "initial_payment", default: "0.0"
    t.decimal "min_capital_payment", default: "0.0"
    t.decimal "min_down_payment_advance"
    t.integer "max_grace_months", default: 0
    t.integer "max_delay_payments", default: 0
    t.boolean "show_rate"
    t.boolean "show_price"
    t.boolean "relative_discount"
    t.integer "immediate_extra_months", default: 0
    t.integer "max_percent_immediate_lots_sold"
    t.integer "min_down_payment", default: 10
    t.boolean "relative_down_payment", default: false
    t.integer "max_finance", default: 0
    t.integer "start_installments"
    t.boolean "initial_payment_active", default: true
    t.boolean "independent_initial_payment", default: true
    t.integer "second_payment", default: 0
    t.integer "max_down_payment_percentage", default: 90
    t.boolean "down_payment_editable", default: true
    t.boolean "initial_payment_editable", default: true
    t.datetime "deleted_at"
    t.boolean "surplus_amount_to_capital_time", default: false, null: false
    t.boolean "requires_file", default: false
    t.bigint "document_template_id"
    t.boolean "consider_residue_in_down_payments", default: false
    t.string "quotation_type"
    t.integer "default_payment"
    t.boolean "has_last_payment", default: false
    t.string "min_last_payment_payment_way", default: "percentage"
    t.decimal "min_last_payment_amount", default: "0.0"
    t.boolean "is_relative_financing", default: false
    t.string "reffered_client_payment_way", default: "amount"
    t.decimal "reffered_client_amount", default: "0.0"
    t.bigint "payment_method_id"
    t.boolean "is_opening_commission", default: false
    t.decimal "opening_commission", default: "0.0"
    t.decimal "cancellation_balance", default: "0.0"
    t.integer "down_payment_balance"
    t.integer "principal_balance"
    t.integer "balance_of_updates"
    t.index ["document_template_id"], name: "index_credit_schemes_on_document_template_id"
    t.index ["payment_method_id"], name: "index_credit_schemes_on_payment_method_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "digital_signature_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "digital_signature_id"
    t.string "status"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["digital_signature_id"], name: "index_digital_signature_logs_on_digital_signature_id"
    t.index ["user_id"], name: "index_digital_signature_logs_on_user_id"
  end

  create_table "digital_signature_participants", force: :cascade do |t|
    t.bigint "digital_signature_id"
    t.string "participant_id"
    t.string "email"
    t.string "sign_url"
    t.string "status"
    t.string "recipient_type"
    t.boolean "email_send", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["digital_signature_id"], name: "index_digital_signature_participants_on_digital_signature_id"
  end

  create_table "digital_signature_services", force: :cascade do |t|
    t.string "name"
    t.string "environment"
    t.boolean "is_automatic"
    t.bigint "enterprise_id"
    t.bigint "step_id"
    t.hstore "properties"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "jump_to_step", default: false
    t.integer "jump_step_id"
    t.bigint "document_template_id"
    t.boolean "is_shield_level_three_clients", default: false
    t.boolean "is_shield_level_three_signers", default: false
    t.string "shield_level_three_message"
    t.boolean "use_email_confirmation", default: false
    t.integer "document_nom_id"
    t.index ["deleted_at"], name: "index_digital_signature_services_on_deleted_at"
    t.index ["document_template_id"], name: "index_digital_signature_services_on_document_template_id"
    t.index ["enterprise_id"], name: "index_digital_signature_services_on_enterprise_id"
    t.index ["step_id"], name: "index_digital_signature_services_on_step_id"
  end

  create_table "digital_signatures", force: :cascade do |t|
    t.bigint "folder_id"
    t.json "response_data"
    t.string "service_type"
    t.string "document_type"
    t.string "document_external_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "digital_signature_service_id"
    t.string "error_description"
    t.boolean "sent_to_clients", default: false
    t.boolean "sent_to_representatives", default: false
    t.datetime "date"
    t.index ["digital_signature_service_id"], name: "index_digital_signatures_on_digital_signature_service_id"
    t.index ["folder_id"], name: "index_digital_signatures_on_folder_id"
  end

  create_table "discounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.decimal "discount"
    t.integer "total_payments"
    t.bigint "stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "dfp"
    t.boolean "is_active", default: true
    t.datetime "deleted_at"
    t.bigint "credit_scheme_id"
    t.index ["credit_scheme_id"], name: "index_discounts_on_credit_scheme_id"
    t.index ["stage_id"], name: "index_discounts_on_stage_id"
  end

  create_table "document_sections", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "action"
    t.integer "order"
  end

  create_table "document_templates", force: :cascade do |t|
    t.string "name"
    t.boolean "requires_approval", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "document_section_id"
    t.string "key"
    t.string "action"
    t.boolean "copy_to_all", default: false
    t.boolean "visible", default: true
    t.integer "order"
    t.string "formats", default: [], array: true
    t.string "doc_type", default: "folder", null: false
    t.string "client_type"
    t.index ["document_section_id"], name: "index_document_templates_on_document_section_id"
  end

  create_table "documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "document_template_id"
    t.string "documentable_type"
    t.bigint "documentable_id"
    t.index ["document_template_id"], name: "index_documents_on_document_template_id"
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable_type_and_documentable_id"
  end

  create_table "down_payments", force: :cascade do |t|
    t.bigint "credit_scheme_id"
    t.integer "term"
    t.decimal "min"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credit_scheme_id"], name: "index_down_payments_on_credit_scheme_id"
  end

  create_table "downloadable_files", force: :cascade do |t|
    t.bigint "step_role_id", null: false
    t.integer "document", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["step_role_id"], name: "index_downloadable_files_on_step_role_id"
  end

  create_table "email_templates", force: :cascade do |t|
    t.string "title"
    t.string "subject"
    t.text "html"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "use_system_template", default: false
  end

  create_table "enterprises", id: :serial, force: :cascade do |t|
    t.string "business_name"
    t.string "short_business_name"
    t.string "rfc"
    t.string "state"
    t.string "country"
    t.string "location"
    t.string "street"
    t.string "outdoor_number"
    t.string "indoor_number"
    t.string "colony"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "postal_code"
    t.boolean "online_payments_enabled", default: false
  end

  create_table "evaluation_folders", id: :serial, force: :cascade do |t|
    t.string "answer"
    t.bigint "evaluation_id"
    t.bigint "folder_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["evaluation_id"], name: "index_evaluation_folders_on_evaluation_id"
    t.index ["folder_id"], name: "index_evaluation_folders_on_folder_id"
    t.index ["user_id"], name: "index_evaluation_folders_on_user_id"
  end

  create_table "evaluation_steps", force: :cascade do |t|
    t.bigint "evaluation_id"
    t.bigint "step_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["evaluation_id"], name: "index_evaluation_steps_on_evaluation_id"
    t.index ["step_id"], name: "index_evaluation_steps_on_step_id"
  end

  create_table "evaluations", id: :serial, force: :cascade do |t|
    t.string "question"
    t.string "question_type"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "file_approvals", id: :serial, force: :cascade do |t|
    t.string "key", null: false
    t.datetime "approved_at"
    t.bigint "approved_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.string "approvable_type"
    t.bigint "approvable_id"
    t.string "comment"
    t.index ["approvable_type", "approvable_id"], name: "index_file_approvals_on_approvable_type_and_approvable_id"
    t.index ["approved_by_id"], name: "index_file_approvals_on_approved_by_id"
  end

  create_table "file_versions", force: :cascade do |t|
    t.bigint "document_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_file_versions_on_document_id"
  end

  create_table "folder_user_concepts", force: :cascade do |t|
    t.string "name"
    t.decimal "commission", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "visible", default: true
    t.string "key"
  end

  create_table "folder_users", id: :serial, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "folder_id"
    t.decimal "percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "concept"
    t.decimal "amount", default: "0.0"
    t.bigint "role_id"
    t.boolean "visible", default: true
    t.bigint "folder_user_concept_id"
    t.datetime "deleted_at"
    t.index ["folder_id"], name: "index_folder_users_on_folder_id"
    t.index ["folder_user_concept_id"], name: "index_folder_users_on_folder_user_concept_id"
    t.index ["role_id"], name: "index_folder_users_on_role_id"
    t.index ["user_id"], name: "index_folder_users_on_user_id"
  end

  create_table "folders", id: :serial, force: :cascade do |t|
    t.bigint "lot_id"
    t.bigint "client_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "active"
    t.date "expiration_date"
    t.string "buyer"
    t.bigint "client_2_id"
    t.bigint "client_3_id"
    t.datetime "start_date"
    t.boolean "is_synchronized", default: false
    t.bigint "deal"
    t.datetime "approved_date"
    t.boolean "ready", default: false, null: false
    t.bigint "contract_id"
    t.bigint "client_4_id"
    t.bigint "client_5_id"
    t.bigint "client_6_id"
    t.bigint "step_id"
    t.string "canceled_description"
    t.bigint "canceled_by"
    t.datetime "canceled_date"
    t.integer "initial_payment_sudden_death"
    t.integer "down_payment_sudden_death"
    t.boolean "reminders_enabled", default: true
    t.text "purchase_conditions"
    t.decimal "total_sale"
    t.boolean "invoice_enabled", default: true
    t.boolean "credit_balance", default: false
    t.index ["client_2_id"], name: "index_folders_on_client_2_id"
    t.index ["client_3_id"], name: "index_folders_on_client_3_id"
    t.index ["client_4_id"], name: "index_folders_on_client_4_id"
    t.index ["client_5_id"], name: "index_folders_on_client_5_id"
    t.index ["client_6_id"], name: "index_folders_on_client_6_id"
    t.index ["client_id"], name: "index_folders_on_client_id"
    t.index ["contract_id"], name: "index_folders_on_contract_id"
    t.index ["lot_id"], name: "index_folders_on_lot_id"
    t.index ["step_id"], name: "index_folders_on_step_id"
    t.index ["user_id"], name: "index_folders_on_user_id"
  end

  create_table "frequent_questions", force: :cascade do |t|
    t.text "title"
    t.text "content"
    t.string "link"
    t.integer "status", default: 0
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_frequent_questions_on_user_id"
  end

  create_table "identification_types", force: :cascade do |t|
    t.string "name"
    t.string "institution"
    t.string "display_as"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "installments", id: :serial, force: :cascade do |t|
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "concept"
    t.bigint "folder_id"
    t.date "date"
    t.decimal "capital"
    t.decimal "interest"
    t.decimal "down_payment"
    t.decimal "total"
    t.decimal "debt"
    t.datetime "deleted_at"
    t.boolean "is_custom", default: false
    t.index ["folder_id"], name: "index_installments_on_folder_id"
  end

  create_table "job_statuses", force: :cascade do |t|
    t.integer "status", default: 0
    t.text "error_message"
    t.text "log"
    t.string "name"
    t.datetime "expires_at"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "action", default: 0
    t.integer "job_id", default: 0
    t.text "description"
    t.integer "canceled_by", default: 0
    t.datetime "canceled_at"
    t.string "job_class"
    t.hstore "job_data"
    t.index ["user_id"], name: "index_job_statuses_on_user_id"
  end

  create_table "lead_sources", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "source_key", default: "", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "logs", id: :serial, force: :cascade do |t|
    t.datetime "date"
    t.string "element_changes"
    t.string "element"
    t.string "element_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_logs_on_user_id"
  end

  create_table "lots", id: :serial, force: :cascade do |t|
    t.string "rid"
    t.string "name"
    t.decimal "depth"
    t.decimal "front"
    t.decimal "area"
    t.decimal "price"
    t.bigint "stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.string "adjoining_north"
    t.string "adjoining_south"
    t.string "adjoining_east"
    t.string "adjoining_west"
    t.decimal "north"
    t.decimal "south"
    t.decimal "east"
    t.decimal "west"
    t.text "description"
    t.string "planking"
    t.string "folio"
    t.integer "number"
    t.string "label"
    t.string "undivided"
    t.string "color"
    t.decimal "fixed_price"
    t.string "colloquial_name"
    t.string "identification_name"
    t.string "owner_name"
    t.decimal "acquisition_cost"
    t.decimal "market_price"
    t.decimal "exchange_rate"
    t.string "vocation"
    t.string "descriptive_status"
    t.string "adjoining_northeast"
    t.string "adjoining_southeast"
    t.string "adjoining_northwest"
    t.string "adjoining_southwest"
    t.decimal "northeast"
    t.decimal "southeast"
    t.decimal "northwest"
    t.decimal "southwest"
    t.string "blocks"
    t.string "geographic_location"
    t.integer "ownership_percent"
    t.string "coowners"
    t.string "liquidity"
    t.index ["stage_id"], name: "index_lots_on_stage_id"
  end

  create_table "moral_clients", id: :serial, force: :cascade do |t|
    t.string "business_name"
    t.string "rfc_company"
    t.string "legal_rfc"
    t.string "legal_name"
    t.string "notary_name"
    t.string "state"
    t.string "country"
    t.string "street"
    t.string "house_number"
    t.string "colony"
    t.string "postal_code"
    t.string "location"
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "city"
    t.string "curp"
    t.string "interior_number"
    t.string "nationality"
    t.string "country_nationality"
    t.string "identification_type"
    t.string "company_identification_type"
    t.string "identification_number"
    t.string "company_identification_number"
    t.string "validity_identification"
    t.string "company_validity_identification"
    t.date "constitution_date"
    t.date "birthdate"
    t.string "activity"
    t.string "notary_public_name"
    t.string "notary_public_number"
    t.string "notary_public_catalog_republic"
    t.string "commercial_electronic_folio_number"
    t.string "public_registry_state"
    t.date "public_registry_date"
    t.bigint "identification_type_id"
    t.bigint "company_identification_type_id"
    t.index ["client_id"], name: "index_moral_clients_on_client_id"
    t.index ["company_identification_type_id"], name: "index_moral_clients_on_company_identification_type_id"
    t.index ["identification_type_id"], name: "index_moral_clients_on_identification_type_id"
  end

  create_table "online_payment_services", force: :cascade do |t|
    t.string "provider"
    t.string "alias"
    t.string "environment"
    t.hstore "properties"
    t.bigint "enterprise_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "bank_account_id"
    t.bigint "payment_method_id"
    t.datetime "deleted_at"
    t.bigint "branch_id"
    t.index ["bank_account_id"], name: "index_online_payment_services_on_bank_account_id"
    t.index ["branch_id"], name: "index_online_payment_services_on_branch_id"
    t.index ["enterprise_id"], name: "index_online_payment_services_on_enterprise_id"
    t.index ["payment_method_id"], name: "index_online_payment_services_on_payment_method_id"
  end

  create_table "online_payment_tickets", force: :cascade do |t|
    t.string "concept"
    t.string "concept_key"
    t.string "sku"
    t.string "amount"
    t.string "token"
    t.string "status"
    t.string "message"
    t.bigint "client_id"
    t.bigint "online_payment_service_id"
    t.bigint "folder_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "response"
    t.boolean "webhook", default: false
    t.index ["client_id"], name: "index_online_payment_tickets_on_client_id"
    t.index ["folder_id"], name: "index_online_payment_tickets_on_folder_id"
    t.index ["online_payment_service_id"], name: "index_online_payment_tickets_on_online_payment_service_id"
  end

  create_table "payment_methods", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "cash_back", default: false
    t.boolean "capital", default: false
    t.boolean "down_payment", default: false
    t.boolean "interest", default: false
    t.boolean "cash_back_folder_exclusivity"
    t.boolean "active", default: true
    t.boolean "add_balance", default: true
    t.datetime "deleted_at"
    t.boolean "reffered_client_cash_back", default: false
    t.boolean "reffered_client_cash_back_multiple", default: false
    t.boolean "payment_is_income", default: false
  end

  create_table "payment_references", force: :cascade do |t|
    t.string "reference"
    t.bigint "folder_id"
    t.json "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_schemes", id: :serial, force: :cascade do |t|
    t.bigint "folder_id"
    t.string "name"
    t.decimal "initial_payment"
    t.decimal "discount"
    t.integer "total_payments"
    t.decimal "dfp"
    t.integer "down_payment_finance"
    t.decimal "down_payment"
    t.decimal "buy_price"
    t.integer "zero_rate"
    t.string "online_payment_id"
    t.boolean "down_payment_paid", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "first_payment", default: 8
    t.integer "start_installments"
    t.decimal "promotion_discount", default: "0.0"
    t.string "promotion_name"
    t.integer "promotion_operation", default: 0
    t.decimal "lock_payment", default: "0.0"
    t.bigint "credit_scheme_id"
    t.integer "immediate_extra_months", default: 0
    t.decimal "opening_commission", default: "0.0"
    t.boolean "is_commissionable", default: true
    t.integer "max_commission_amount"
    t.boolean "compound_interest", default: true
    t.boolean "independent_initial_payment", default: true
    t.date "delivery_date"
    t.integer "second_payment", default: 0
    t.boolean "initial_payment_active", default: true
    t.bigint "promotion_id"
    t.bigint "coupon_id"
    t.decimal "area"
    t.boolean "with_last_payment", default: false
    t.decimal "last_payment_amount", default: "0.0"
    t.boolean "is_relative_financing", default: false
    t.index ["coupon_id"], name: "index_payment_schemes_on_coupon_id"
    t.index ["credit_scheme_id"], name: "index_payment_schemes_on_credit_scheme_id"
    t.index ["folder_id"], name: "index_payment_schemes_on_folder_id"
    t.index ["promotion_id"], name: "index_payment_schemes_on_promotion_id"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "amount"
    t.bigint "installment_id"
    t.bigint "user_id"
    t.bigint "client_id"
    t.bigint "branch_id"
    t.string "status", default: "active"
    t.datetime "deleted_at"
    t.integer "canceled_by"
    t.bigint "cash_flow_id"
    t.datetime "cancelation_date"
    t.string "cancelation_description"
    t.index ["branch_id"], name: "index_payments_on_branch_id"
    t.index ["cash_flow_id"], name: "index_payments_on_cash_flow_id"
    t.index ["client_id"], name: "index_payments_on_client_id"
    t.index ["installment_id"], name: "index_payments_on_installment_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "penalties", force: :cascade do |t|
    t.bigint "installment_id"
    t.bigint "user_id"
    t.bigint "canceled_by"
    t.boolean "active", default: true
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["installment_id"], name: "index_penalties_on_installment_id"
    t.index ["user_id"], name: "index_penalties_on_user_id"
  end

  create_table "periods", id: :serial, force: :cascade do |t|
    t.integer "payments"
    t.decimal "interest"
    t.integer "order"
    t.bigint "credit_scheme_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credit_scheme_id"], name: "index_periods_on_credit_scheme_id"
  end

  create_table "permissions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "subject_class"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.boolean "hidden", default: false, null: false
  end

  create_table "phases", id: :serial, force: :cascade do |t|
    t.text "name"
    t.date "start_date"
    t.bigint "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reference"
    t.integer "order"
    t.datetime "deleted_at"
    t.string "slug"
    t.index ["project_id"], name: "index_phases_on_project_id"
    t.index ["slug", "project_id"], name: "index_phases_on_slug_and_project_id", unique: true
  end

  create_table "physical_clients", id: :serial, force: :cascade do |t|
    t.string "rfc"
    t.string "place_birth"
    t.string "birthdate"
    t.string "nationality"
    t.string "civil_status"
    t.string "regime"
    t.string "state"
    t.string "country"
    t.string "street"
    t.string "house_number"
    t.string "colony"
    t.string "postal_code"
    t.string "location"
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "occupation"
    t.string "city"
    t.string "identification_type"
    t.string "identification_number"
    t.string "curp"
    t.string "validity_identification"
    t.string "interior_number"
    t.bigint "identification_type_id"
    t.index ["client_id"], name: "index_physical_clients_on_client_id"
    t.index ["identification_type_id"], name: "index_physical_clients_on_identification_type_id"
  end

  create_table "project_users", id: :serial, force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_users_on_project_id"
    t.index ["user_id"], name: "index_project_users_on_user_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
    t.string "currency"
    t.string "email"
    t.string "phone"
    t.string "quotation", default: "new"
    t.string "reference"
    t.integer "order"
    t.string "project_entity_name", default: "Proyecto"
    t.string "phase_entity_name", default: "Fase"
    t.string "stage_entity_name", default: "Etapa"
    t.string "lot_entity_name", default: "Lote"
    t.datetime "deleted_at"
    t.string "facebook"
    t.string "instagram"
    t.string "website"
    t.string "color", default: "#000000"
    t.string "subtitle_color", default: "#000000"
    t.string "divider_color", default: "#000000"
    t.string "font_color", default: "#FFFFFF"
    t.string "slug"
    t.boolean "show_amortization_table", default: false
    t.boolean "show_rate", default: false
    t.boolean "show_price", default: false
    t.boolean "show_bank_account", default: false
    t.boolean "show_final_price", default: false
    t.boolean "show_payment_dates", default: true
    t.index ["slug"], name: "index_projects_on_slug", unique: true
  end

  create_table "promotions", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.date "start_date", default: -> { "CURRENT_DATE" }, null: false
    t.date "end_date"
    t.decimal "amount", default: "0.0", null: false
    t.decimal "min_area", default: "0.0", null: false
    t.decimal "max_area"
    t.integer "operation", default: 0, null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "term_min", default: 0, null: false
    t.integer "term_max"
    t.integer "downpayment_min", default: 0, null: false
    t.integer "downpayment_max"
    t.decimal "downpayment_amount"
    t.integer "downpayment_type"
    t.decimal "initialpayment_amount"
    t.integer "initialpayment_type"
    t.integer "max_days_for_first_payment"
    t.boolean "downpayment_editable"
    t.boolean "initialpayment_editable"
    t.integer "no_interest_installments"
    t.integer "start_installments"
    t.integer "zero_rate_extra", default: 0
    t.boolean "is_commissionable", default: true
    t.boolean "draft", default: true
    t.datetime "deleted_at"
    t.boolean "enabled_coupons", default: false
    t.boolean "show_percentage", default: true
    t.integer "discount_type"
  end

  create_table "quote_logs", force: :cascade do |t|
    t.bigint "lot_id"
    t.bigint "client_id"
    t.bigint "user_id"
    t.bigint "folder_id"
    t.date "creation_date", default: -> { "CURRENT_TIMESTAMP" }
    t.boolean "email_delivered", default: false
    t.boolean "downloaded", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_quote_logs_on_client_id"
    t.index ["folder_id"], name: "index_quote_logs_on_folder_id"
    t.index ["lot_id"], name: "index_quote_logs_on_lot_id"
    t.index ["user_id"], name: "index_quote_logs_on_user_id"
  end

  create_table "quote_roles", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.integer "min_months_deferred_down_payment"
    t.integer "max_months_deferred_down_payment"
    t.integer "min_days_first_monthly_payment"
    t.integer "max_days_first_monthly_payment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "min_days_second_monthly_payment"
    t.integer "max_days_second_monthly_payment"
    t.index ["role_id"], name: "index_quote_roles_on_role_id"
  end

  create_table "reference_contacts", force: :cascade do |t|
    t.bigint "client_id"
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "concept"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_reference_contacts_on_client_id"
  end

  create_table "referents", id: :serial, force: :cascade do |t|
    t.integer "referrer_id"
    t.integer "invited_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "referred_clients", force: :cascade do |t|
    t.bigint "client_id"
    t.bigint "referred_client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_referred_clients_on_client_id"
    t.index ["referred_client_id"], name: "index_referred_clients_on_referred_client_id"
  end

  create_table "restructures", force: :cascade do |t|
    t.bigint "payment_id"
    t.string "concept"
    t.integer "current_term"
    t.decimal "current_discount"
    t.integer "current_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "grace_months", default: 0
    t.integer "delay_months", default: 0
    t.boolean "without_promotions", default: false
    t.index ["payment_id"], name: "index_restructures_on_payment_id"
  end

  create_table "role_permissions", id: :serial, force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "permission_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_evo", default: false
    t.boolean "hidden", default: false, null: false
    t.datetime "deleted_at"
    t.integer "level"
    t.float "sale_commission", default: 0.0
    t.integer "maximum_schemes", default: 0
    t.float "commission_monitoring", default: 0.0
  end

  create_table "roles_client_user_concepts", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "client_user_concept_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_user_concept_id"], name: "index_roles_client_user_concepts_on_client_user_concept_id"
    t.index ["role_id"], name: "index_roles_client_user_concepts_on_role_id"
  end

  create_table "roles_folder_user_concepts", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "folder_user_concept_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["folder_user_concept_id"], name: "index_roles_folder_user_concepts_on_folder_user_concept_id"
    t.index ["role_id"], name: "index_roles_folder_user_concepts_on_role_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "key"
    t.string "data_type"
    t.string "label"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "concept"
    t.boolean "hidden", default: false, null: false
    t.string "var"
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  create_table "signers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "definition"
    t.string "role"
    t.string "company"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "first_surname"
    t.string "second_surname"
    t.boolean "is_an_observer", default: false
    t.string "phone"
  end

  create_table "stage_additional_concepts", force: :cascade do |t|
    t.bigint "additional_concept_id"
    t.bigint "stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["additional_concept_id"], name: "index_stage_additional_concepts_on_additional_concept_id"
    t.index ["stage_id"], name: "index_stage_additional_concepts_on_stage_id"
  end

  create_table "stage_contracts", force: :cascade do |t|
    t.bigint "stage_id"
    t.bigint "contract_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_stage_contracts_on_contract_id"
    t.index ["stage_id"], name: "index_stage_contracts_on_stage_id"
  end

  create_table "stage_promotions", id: :serial, force: :cascade do |t|
    t.bigint "promotion_id"
    t.bigint "stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["promotion_id"], name: "index_stage_promotions_on_promotion_id"
    t.index ["stage_id"], name: "index_stage_promotions_on_stage_id"
  end

  create_table "stage_users", id: :serial, force: :cascade do |t|
    t.bigint "stage_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stage_id"], name: "index_stage_users_on_stage_id"
    t.index ["user_id"], name: "index_stage_users_on_user_id"
  end

  create_table "stages", id: :serial, force: :cascade do |t|
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.boolean "active", default: true
    t.bigint "phase_id"
    t.bigint "enterprise_id"
    t.date "release_date"
    t.string "stage_type"
    t.integer "order"
    t.integer "initial_payment_expiration", default: 1
    t.string "reference"
    t.integer "down_payment_expiration", default: 120
    t.integer "lock_seller_period"
    t.integer "payment_expiration", default: 7
    t.string "payment_email"
    t.bigint "credit_scheme_id"
    t.string "payment_receptor_emails", array: true
    t.text "lot_description"
    t.boolean "show_full_name", default: true
    t.integer "sort"
    t.boolean "active_annexes", default: false
    t.string "start_date_by", default: "stage_date"
    t.boolean "show_price", default: false
    t.boolean "show_rate", default: false
    t.decimal "opening_commission"
    t.boolean "active_commissions", default: true
    t.integer "max_commission_amount", default: 0
    t.integer "sudden_death", default: 5
    t.text "observations"
    t.boolean "active_messages", default: false
    t.boolean "is_expirable", default: false
    t.boolean "active_mails", default: false
    t.text "purchase_conditions"
    t.string "lot_description_title"
    t.date "delivery_date"
    t.string "stage_description_title"
    t.string "phase_description_title"
    t.datetime "deleted_at"
    t.bigint "commission_scheme_id"
    t.text "receipt_observations"
    t.string "slug"
    t.bigint "owner_enterprise_id"
    t.index ["commission_scheme_id"], name: "index_stages_on_commission_scheme_id"
    t.index ["credit_scheme_id"], name: "index_stages_on_credit_scheme_id"
    t.index ["enterprise_id"], name: "index_stages_on_enterprise_id"
    t.index ["owner_enterprise_id"], name: "index_stages_on_owner_enterprise_id"
    t.index ["phase_id"], name: "index_stages_on_phase_id"
    t.index ["slug", "phase_id"], name: "index_stages_on_slug_and_phase_id", unique: true
  end

  create_table "stages_commission_schemes_roles", force: :cascade do |t|
    t.bigint "stage_id"
    t.bigint "commission_schemes_role_id"
    t.string "users", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commission_schemes_role_id"], name: "index_stagescommissionschemesroles_on_commissionschemesroleid"
    t.index ["stage_id"], name: "index_stages_commission_schemes_roles_on_stage_id"
  end

  create_table "step_document_templates", force: :cascade do |t|
    t.bigint "step_id"
    t.bigint "document_template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_template_id"], name: "index_step_document_templates_on_document_template_id"
    t.index ["step_id"], name: "index_step_document_templates_on_step_id"
  end

  create_table "step_documents", force: :cascade do |t|
    t.bigint "step_id", null: false
    t.bigint "document_template_id", null: false
    t.boolean "required", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_template_id"], name: "index_step_documents_on_document_template_id"
    t.index ["step_id"], name: "index_step_documents_on_step_id"
  end

  create_table "step_logs", force: :cascade do |t|
    t.bigint "step_id"
    t.bigint "folder_id", null: false
    t.bigint "user_id"
    t.string "status", null: false
    t.datetime "moved_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "action"
    t.index ["folder_id"], name: "index_step_logs_on_folder_id"
    t.index ["step_id"], name: "index_step_logs_on_step_id"
    t.index ["user_id"], name: "index_step_logs_on_user_id"
  end

  create_table "step_role_document_templates", force: :cascade do |t|
    t.bigint "step_role_id"
    t.bigint "document_template_id", null: false
    t.boolean "readable", default: false
    t.boolean "editable", default: false
    t.boolean "uploadable", default: false
    t.boolean "destroyable", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_template_id"], name: "index_step_role_document_templates_on_document_template_id"
    t.index ["step_role_id"], name: "index_step_role_document_templates_on_step_role_id"
  end

  create_table "step_roles", force: :cascade do |t|
    t.bigint "step_id"
    t.bigint "role_id"
    t.boolean "update_financial", default: false
    t.boolean "update_coowners", default: false
    t.boolean "can_cancel", default: false
    t.boolean "can_approve", default: false
    t.boolean "can_soft_reject", default: false
    t.boolean "can_reject", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "visible", default: true
    t.boolean "can_make_installments", default: false
    t.boolean "can_comment", default: true
    t.boolean "can_manage_reminders", default: false
    t.boolean "can_add_folder_user", default: false
    t.boolean "can_edit_folder_user", default: false
    t.boolean "can_remove_folder_user", default: false
    t.boolean "can_send_to_sign_purchase_promise", default: false
    t.boolean "can_send_to_cancel_sign_purchase_promise", default: false
    t.boolean "can_resend_sign_files", default: false
    t.boolean "send_by_whatsapp", default: false
    t.boolean "send_by_email", default: false
    t.boolean "copy_to_clipboard", default: false
    t.boolean "show_clients_signature_links", default: false
    t.boolean "show_signers_signature_links", default: false
    t.boolean "can_send_signature_link_by_whatsapp", default: false
    t.boolean "can_send_signature_link_by_email", default: false
    t.boolean "can_send_signature_link_by_clipboard", default: false
    t.boolean "can_manage_custom_installments", default: false
    t.boolean "can_reassign_client", default: false
    t.boolean "can_reassign_seller", default: false
    t.index ["role_id"], name: "index_step_roles_on_role_id"
    t.index ["step_id"], name: "index_step_roles_on_step_id"
  end

  create_table "steps", force: :cascade do |t|
    t.string "name"
    t.integer "order"
    t.integer "reject_step_id"
    t.integer "hubspot_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "installments_step", default: false
    t.integer "lot_status", default: 1
    t.boolean "folders_expires", default: false
    t.bigint "folder_user_concept_id"
    t.boolean "blocked", default: false
    t.integer "folders_count", default: 0
    t.boolean "send_payment_reminder", default: false
    t.bigint "client_user_concept_id"
    t.index ["client_user_concept_id"], name: "index_steps_on_client_user_concept_id"
    t.index ["folder_user_concept_id"], name: "index_steps_on_folder_user_concept_id"
    t.index ["reject_step_id"], name: "index_steps_on_reject_step_id"
  end

  create_table "structures", id: :serial, force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "user_id"
    t.string "ancestry"
    t.integer "max_branches", default: 5
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ancestry_depth", default: 0
    t.datetime "deleted_at"
    t.index ["ancestry"], name: "index_structures_on_ancestry"
    t.index ["role_id"], name: "index_structures_on_role_id"
    t.index ["user_id"], name: "index_structures_on_user_id"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.decimal "amount"
    t.integer "payments_count"
    t.string "concept_description"
    t.date "start_date"
    t.date "end_date"
    t.bigint "subscription_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_subscription_plans_on_subscription_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "folder_id"
    t.string "subscription_id", null: false
    t.string "status", null: false
    t.integer "exp_year", null: false
    t.integer "exp_month", null: false
    t.string "last_four_digits", null: false
    t.datetime "last_update", default: -> { "CURRENT_DATE" }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "client_id"
    t.date "billing_start"
    t.date "billing_end"
    t.string "concept_key"
    t.bigint "online_payment_service_id"
    t.string "online_plan_id"
    t.boolean "allow_update", default: false
    t.index ["client_id"], name: "index_subscriptions_on_client_id"
    t.index ["folder_id"], name: "index_subscriptions_on_folder_id"
    t.index ["online_payment_service_id"], name: "index_subscriptions_on_online_payment_service_id"
  end

  create_table "support_sales", force: :cascade do |t|
    t.string "status", null: false
    t.bigint "folder_id", null: false
    t.bigint "requester_id", null: false
    t.bigint "supporter_id"
    t.bigint "support_coordinator_id"
    t.bigint "support_manager_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "support_vicedirector_id"
    t.index ["folder_id"], name: "index_support_sales_on_folder_id"
    t.index ["requester_id"], name: "index_support_sales_on_requester_id"
    t.index ["support_coordinator_id"], name: "index_support_sales_on_support_coordinator_id"
    t.index ["support_manager_id"], name: "index_support_sales_on_support_manager_id"
    t.index ["support_vicedirector_id"], name: "index_support_sales_on_support_vicedirector_id"
    t.index ["supporter_id"], name: "index_support_sales_on_supporter_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "key", default: "", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "related_to", default: "contracts"
  end

  create_table "tiny_uploads", force: :cascade do |t|
    t.string "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_announcements", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "announcement_id"
    t.index ["announcement_id"], name: "index_user_announcements_on_announcement_id"
    t.index ["user_id"], name: "index_user_announcements_on_user_id"
  end

  create_table "user_clients", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.integer "client_id"
    t.datetime "last_sign_in_at"
    t.index ["confirmation_token"], name: "index_user_clients_on_confirmation_token", unique: true
    t.index ["email"], name: "index_user_clients_on_email", unique: true
    t.index ["reset_password_token"], name: "index_user_clients_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_user_clients_on_uid_and_provider", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.string "phone", default: ""
    t.bigint "branch_id"
    t.boolean "is_active", default: true
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.integer "created_by"
    t.bigint "role_id"
    t.string "written_rfc"
    t.string "written_curp"
    t.date "birthdate"
    t.string "gender"
    t.datetime "activated_at"
    t.datetime "disabled_at"
    t.bigint "company_id"
    t.index ["branch_id"], name: "index_users_on_branch_id"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "additional_concept_payments", "additional_concepts"
  add_foreign_key "additional_concept_payments", "cash_flows"
  add_foreign_key "additional_concept_payments", "enterprises"
  add_foreign_key "additional_concepts", "enterprises"
  add_foreign_key "automated_email_client_concepts", "automated_emails"
  add_foreign_key "automated_email_client_concepts", "client_user_concepts"
  add_foreign_key "automated_email_user_concepts", "automated_emails"
  add_foreign_key "automated_email_user_concepts", "folder_user_concepts"
  add_foreign_key "automated_emails", "email_templates"
  add_foreign_key "automated_emails", "folder_user_concepts"
  add_foreign_key "automated_emails", "steps"
  add_foreign_key "blueprint_lots", "blueprints"
  add_foreign_key "blueprint_lots", "lots"
  add_foreign_key "blueprint_stages", "blueprints"
  add_foreign_key "blueprint_stages", "stages"
  add_foreign_key "cash_back_flows", "cash_backs"
  add_foreign_key "cash_back_flows", "cash_flows"
  add_foreign_key "cash_backs", "clients"
  add_foreign_key "cash_backs", "folders", column: "exclusive_folder_id"
  add_foreign_key "cash_backs", "payment_methods"
  add_foreign_key "cash_flows", "bank_accounts"
  add_foreign_key "cash_flows", "branches"
  add_foreign_key "cash_flows", "clients"
  add_foreign_key "cash_flows", "folders"
  add_foreign_key "cash_flows", "payment_methods"
  add_foreign_key "classifier_roles", "classifiers"
  add_foreign_key "classifier_roles", "roles"
  add_foreign_key "classifier_users", "classifiers"
  add_foreign_key "classifiers_roles", "classifiers"
  add_foreign_key "classifiers_roles", "roles"
  add_foreign_key "classifiers_users", "classifiers"
  add_foreign_key "client_user_concepts", "roles"
  add_foreign_key "client_users", "client_user_concepts"
  add_foreign_key "client_users", "clients"
  add_foreign_key "clients", "lead_sources"
  add_foreign_key "comments", "folders"
  add_foreign_key "commission_schemes_roles", "commission_schemes"
  add_foreign_key "commission_schemes_roles", "folder_user_concepts"
  add_foreign_key "commission_schemes_roles", "roles"
  add_foreign_key "commissions", "folder_users"
  add_foreign_key "commissions", "installments"
  add_foreign_key "commissions", "payment_methods"
  add_foreign_key "commissions", "payments"
  add_foreign_key "contract_annexes", "contracts"
  add_foreign_key "contract_client_documents", "contracts"
  add_foreign_key "contract_document_templates", "contracts"
  add_foreign_key "contract_document_templates", "document_templates"
  add_foreign_key "contract_non_signers", "contracts"
  add_foreign_key "contract_non_signers", "signers", column: "non_signer_id"
  add_foreign_key "contract_signers", "contracts"
  add_foreign_key "contract_signers", "signers"
  add_foreign_key "coupons", "promotions"
  add_foreign_key "credit_schemes", "document_templates"
  add_foreign_key "credit_schemes", "payment_methods"
  add_foreign_key "digital_signature_logs", "digital_signatures"
  add_foreign_key "digital_signature_participants", "digital_signatures"
  add_foreign_key "digital_signature_services", "document_templates"
  add_foreign_key "digital_signature_services", "enterprises"
  add_foreign_key "digital_signature_services", "steps"
  add_foreign_key "digital_signatures", "digital_signature_services"
  add_foreign_key "digital_signatures", "folders"
  add_foreign_key "discounts", "credit_schemes"
  add_foreign_key "discounts", "stages"
  add_foreign_key "document_templates", "document_sections"
  add_foreign_key "documents", "document_templates"
  add_foreign_key "down_payments", "credit_schemes"
  add_foreign_key "downloadable_files", "step_roles"
  add_foreign_key "evaluation_folders", "evaluations"
  add_foreign_key "evaluation_folders", "folders"
  add_foreign_key "evaluation_steps", "evaluations"
  add_foreign_key "evaluation_steps", "steps"
  add_foreign_key "file_versions", "documents"
  add_foreign_key "folder_users", "folder_user_concepts"
  add_foreign_key "folder_users", "folders"
  add_foreign_key "folder_users", "roles"
  add_foreign_key "folders", "clients"
  add_foreign_key "folders", "clients", column: "client_2_id"
  add_foreign_key "folders", "clients", column: "client_3_id"
  add_foreign_key "folders", "clients", column: "client_4_id"
  add_foreign_key "folders", "clients", column: "client_5_id"
  add_foreign_key "folders", "clients", column: "client_6_id"
  add_foreign_key "folders", "contracts"
  add_foreign_key "folders", "lots"
  add_foreign_key "folders", "steps"
  add_foreign_key "frequent_questions", "users"
  add_foreign_key "installments", "folders"
  add_foreign_key "lots", "stages"
  add_foreign_key "moral_clients", "clients"
  add_foreign_key "moral_clients", "identification_types"
  add_foreign_key "moral_clients", "identification_types", column: "company_identification_type_id"
  add_foreign_key "online_payment_services", "bank_accounts"
  add_foreign_key "online_payment_services", "branches"
  add_foreign_key "online_payment_services", "enterprises"
  add_foreign_key "online_payment_services", "payment_methods"
  add_foreign_key "online_payment_tickets", "clients"
  add_foreign_key "online_payment_tickets", "folders"
  add_foreign_key "online_payment_tickets", "online_payment_services"
  add_foreign_key "payment_schemes", "coupons"
  add_foreign_key "payment_schemes", "credit_schemes"
  add_foreign_key "payment_schemes", "folders"
  add_foreign_key "payment_schemes", "promotions"
  add_foreign_key "payments", "branches"
  add_foreign_key "payments", "cash_flows"
  add_foreign_key "payments", "clients"
  add_foreign_key "payments", "installments"
  add_foreign_key "penalties", "installments"
  add_foreign_key "periods", "credit_schemes"
  add_foreign_key "phases", "projects"
  add_foreign_key "physical_clients", "clients"
  add_foreign_key "physical_clients", "identification_types"
  add_foreign_key "project_users", "projects"
  add_foreign_key "quote_logs", "clients"
  add_foreign_key "quote_logs", "folders"
  add_foreign_key "quote_logs", "lots"
  add_foreign_key "quote_roles", "roles"
  add_foreign_key "reference_contacts", "clients"
  add_foreign_key "referred_clients", "clients"
  add_foreign_key "referred_clients", "clients", column: "referred_client_id"
  add_foreign_key "restructures", "payments"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "roles_client_user_concepts", "client_user_concepts"
  add_foreign_key "roles_client_user_concepts", "roles"
  add_foreign_key "roles_folder_user_concepts", "folder_user_concepts"
  add_foreign_key "roles_folder_user_concepts", "roles"
  add_foreign_key "stage_additional_concepts", "additional_concepts"
  add_foreign_key "stage_additional_concepts", "stages"
  add_foreign_key "stage_contracts", "contracts"
  add_foreign_key "stage_contracts", "stages"
  add_foreign_key "stage_promotions", "promotions"
  add_foreign_key "stage_promotions", "stages"
  add_foreign_key "stage_users", "stages"
  add_foreign_key "stages", "commission_schemes"
  add_foreign_key "stages", "credit_schemes"
  add_foreign_key "stages", "enterprises"
  add_foreign_key "stages", "enterprises", column: "owner_enterprise_id"
  add_foreign_key "stages", "phases"
  add_foreign_key "stages_commission_schemes_roles", "commission_schemes_roles"
  add_foreign_key "stages_commission_schemes_roles", "stages"
  add_foreign_key "step_document_templates", "document_templates"
  add_foreign_key "step_document_templates", "steps"
  add_foreign_key "step_documents", "document_templates"
  add_foreign_key "step_documents", "steps"
  add_foreign_key "step_logs", "folders"
  add_foreign_key "step_logs", "steps"
  add_foreign_key "step_role_document_templates", "document_templates"
  add_foreign_key "step_role_document_templates", "step_roles"
  add_foreign_key "step_roles", "roles"
  add_foreign_key "step_roles", "steps"
  add_foreign_key "steps", "client_user_concepts"
  add_foreign_key "steps", "folder_user_concepts"
  add_foreign_key "steps", "steps", column: "reject_step_id"
  add_foreign_key "structures", "roles"
  add_foreign_key "subscriptions", "clients"
  add_foreign_key "subscriptions", "folders"
  add_foreign_key "subscriptions", "online_payment_services"
  add_foreign_key "support_sales", "folders"
  add_foreign_key "users", "branches"
  add_foreign_key "users", "companies"
  add_foreign_key "users", "roles"
  add_foreign_key "users", "users", column: "created_by"
end
