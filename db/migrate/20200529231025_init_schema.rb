# frozen_string_literal: true

class InitSchema < ActiveRecord::Migration[5.0]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    create_table "active_storage_attachments" do |t|
      t.string "name", null: false
      t.string "record_type", null: false
      t.bigint "record_id", null: false
      t.bigint "blob_id", null: false
      t.datetime "created_at", null: false
      t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
      t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
    end
    create_table "active_storage_blobs" do |t|
      t.string "key", null: false
      t.string "filename", null: false
      t.string "content_type"
      t.text "metadata"
      t.bigint "byte_size", null: false
      t.string "checksum", null: false
      t.datetime "created_at", null: false
      t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
    end
    create_table "api_keys" do |t|
      t.string "private_key", default: "", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "public_key"
    end
    create_table "bank_accounts" do |t|
      t.string "holder"
      t.string "bank"
      t.string "account_number"
      t.string "currency"
      t.string "clabe"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "enterprise_id"
      t.boolean "active", default: true
      t.index ["enterprise_id"], name: "index_bank_accounts_on_enterprise_id"
    end
    create_table "base_commissions" do |t|
      t.bigint "user_id"
      t.bigint "folder_id"
      t.decimal "percentage"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["folder_id"], name: "index_base_commissions_on_folder_id"
      t.index ["user_id"], name: "index_base_commissions_on_user_id"
    end
    create_table "blueprint_lots" do |t|
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
    create_table "blueprints" do |t|
      t.string "available_color"
      t.string "reserved_color"
      t.string "sold_color"
      t.string "styles"
      t.bigint "stage_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "view_box"
      t.string "style"
      t.string "locked_color"
      t.index ["stage_id"], name: "index_blueprints_on_stage_id"
    end
    create_table "branches" do |t|
      t.string "name"
      t.string "address"
      t.string "phone"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "active", default: false
    end
    create_table "clients" do |t|
      t.string "rid"
      t.string "name"
      t.string "first_surname"
      t.string "second_surname"
      t.string "main_phone"
      t.string "optional_phone"
      t.string "email"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "user_id"
      t.string "person"
      t.string "gender"
      t.integer "origin"
      t.string "branch"
      t.index ["email"], name: "index_clients_on_email", unique: true
      t.index ["user_id"], name: "index_clients_on_user_id"
    end
    create_table "comments" do |t|
      t.text "reason"
      t.bigint "folder_id"
      t.bigint "user_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["folder_id"], name: "index_comments_on_folder_id"
      t.index ["user_id"], name: "index_comments_on_user_id"
    end
    create_table "commissions" do |t|
      t.bigint "base_commission_id"
      t.decimal "amount"
      t.boolean "paid", default: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "installment_id"
      t.index ["base_commission_id"], name: "index_commissions_on_base_commission_id"
      t.index ["installment_id"], name: "index_commissions_on_installment_id"
    end
    create_table "contract_signers" do |t|
      t.bigint "contract_id"
      t.bigint "signer_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["contract_id"], name: "index_contract_signers_on_contract_id"
      t.index ["signer_id"], name: "index_contract_signers_on_signer_id"
    end
    create_table "contracts" do |t|
      t.string "key"
      t.string "data_type"
      t.string "label"
      t.text "value"
      t.bigint "project_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "buyer_definition"
      t.string "coowner_1_definition"
      t.string "coowner_2_definition"
      t.integer "contract_type"
      t.string "coowner_3_definition"
      t.string "coowner_4_definition"
      t.string "coowner_5_definition"
      t.index ["project_id"], name: "index_contracts_on_project_id"
    end
    create_table "coordinators" do |t|
      t.bigint "user_id"
      t.bigint "manager_id"
      t.decimal "commission"
      t.integer "max_branches"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "active", default: false
      t.decimal "sale_commission"
      t.index ["manager_id"], name: "index_coordinators_on_manager_id"
      t.index ["user_id"], name: "index_coordinators_on_user_id"
    end
    create_table "credit_schemes" do |t|
      t.string "name"
      t.boolean "status"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "directors" do |t|
      t.bigint "user_id"
      t.integer "max_branches"
      t.boolean "active", default: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["user_id"], name: "index_directors_on_user_id"
    end
    create_table "enterprises" do |t|
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
      t.string "rid"
      t.string "postal_code"
      t.string "transaction_merchant_id"
      t.string "transaction_public_key"
      t.string "transaction_private_key"
    end
    create_table "evaluation_folders" do |t|
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
    create_table "evaluations" do |t|
      t.string "question"
      t.string "question_type"
      t.boolean "active", default: true
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "file_approvals" do |t|
      t.string "key", null: false
      t.datetime "approved_at"
      t.bigint "approved_by_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "status", default: 0
      t.string "approvable_type"
      t.bigint "approvable_id"
      t.index ["approvable_type", "approvable_id"], name: "index_file_approvals_on_approvable_type_and_approvable_id"
      t.index ["approved_by_id"], name: "index_file_approvals_on_approved_by_id"
    end
    create_table "folders" do |t|
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
      t.string "rid"
      t.boolean "is_synchronized", default: false
      t.integer "deal"
      t.date "approved_date"
      t.boolean "ready", default: false, null: false
      t.bigint "contract_id"
      t.bigint "client_4_id"
      t.bigint "client_5_id"
      t.bigint "client_6_id"
      t.index ["client_2_id"], name: "index_folders_on_client_2_id"
      t.index ["client_3_id"], name: "index_folders_on_client_3_id"
      t.index ["client_4_id"], name: "index_folders_on_client_4_id"
      t.index ["client_5_id"], name: "index_folders_on_client_5_id"
      t.index ["client_6_id"], name: "index_folders_on_client_6_id"
      t.index ["client_id"], name: "index_folders_on_client_id"
      t.index ["contract_id"], name: "index_folders_on_contract_id"
      t.index ["lot_id"], name: "index_folders_on_lot_id"
      t.index ["user_id"], name: "index_folders_on_user_id"
    end
    create_table "installments" do |t|
      t.integer "number"
      t.date "date"
      t.decimal "capital", default: "0.0"
      t.decimal "interest", default: "0.0"
      t.decimal "down_payment", default: "0.0"
      t.decimal "total", default: "0.0"
      t.decimal "debt", default: "0.0"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "concept"
      t.bigint "folder_id"
      t.index ["folder_id"], name: "index_installments_on_folder_id"
    end
    create_table "logs" do |t|
      t.datetime "date"
      t.string "element_changes"
      t.string "element"
      t.string "element_id"
      t.bigint "user_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["user_id"], name: "index_logs_on_user_id"
    end
    create_table "lots" do |t|
      t.string "rid"
      t.string "name"
      t.decimal "depht"
      t.decimal "front"
      t.decimal "area"
      t.decimal "price"
      t.bigint "stage_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "status", default: 0
      t.index ["stage_id"], name: "index_lots_on_stage_id"
    end
    create_table "managers" do |t|
      t.bigint "user_id"
      t.bigint "vice_director_id"
      t.decimal "commission"
      t.integer "max_branches"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "active", default: false
      t.decimal "sale_commission"
      t.index ["user_id"], name: "index_managers_on_user_id"
      t.index ["vice_director_id"], name: "index_managers_on_vice_director_id"
    end
    create_table "moral_clients" do |t|
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
      t.index ["client_id"], name: "index_moral_clients_on_client_id"
    end
    create_table "payment_methods" do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "payment_plans" do |t|
      t.string "rid"
      t.string "name"
      t.decimal "discount"
      t.integer "total_payments"
      t.bigint "stage_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.decimal "dfp"
      t.boolean "is_active", default: true
      t.index ["stage_id"], name: "index_payment_plans_on_stage_id"
    end
    create_table "payment_schemes" do |t|
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
      t.string "formula"
      t.integer "start_installments"
      t.decimal "promotion", default: "0.0"
      t.string "promotion_name"
      t.integer "promotion_operation", default: 0
      t.decimal "lock_payment", default: "0.0"
      t.bigint "credit_scheme_id"
      t.index ["credit_scheme_id"], name: "index_payment_schemes_on_credit_scheme_id"
      t.index ["folder_id"], name: "index_payment_schemes_on_folder_id"
    end
    create_table "payments" do |t|
      t.date "date"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.decimal "amount"
      t.string "folio"
      t.boolean "is_capital", default: false
      t.bigint "installment_id"
      t.bigint "payment_method_id"
      t.bigint "user_id"
      t.bigint "client_id"
      t.bigint "branch_id"
      t.bigint "bank_account_id"
      t.string "concept"
      t.integer "current_term"
      t.decimal "current_discount"
      t.string "charge_id"
      t.index ["bank_account_id"], name: "index_payments_on_bank_account_id"
      t.index ["branch_id"], name: "index_payments_on_branch_id"
      t.index ["client_id"], name: "index_payments_on_client_id"
      t.index ["installment_id"], name: "index_payments_on_installment_id"
      t.index ["payment_method_id"], name: "index_payments_on_payment_method_id"
      t.index ["user_id"], name: "index_payments_on_user_id"
    end
    create_table "periods" do |t|
      t.integer "payments"
      t.decimal "interest"
      t.integer "order"
      t.bigint "credit_scheme_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["credit_scheme_id"], name: "index_periods_on_credit_scheme_id"
    end
    create_table "permissions" do |t|
      t.string "name"
      t.string "subject_class"
      t.string "action"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.text "description"
    end
    create_table "phases" do |t|
      t.text "name"
      t.date "start_date"
      t.bigint "project_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "rid"
      t.string "reference"
      t.index ["project_id"], name: "index_phases_on_project_id"
    end
    create_table "physical_clients" do |t|
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
      t.index ["client_id"], name: "index_physical_clients_on_client_id"
    end
    create_table "project_sellers" do |t|
      t.bigint "project_id"
      t.bigint "user_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["project_id"], name: "index_project_sellers_on_project_id"
      t.index ["user_id"], name: "index_project_sellers_on_user_id"
    end
    create_table "projects" do |t|
      t.string "rid"
      t.string "name"
      t.string "logo"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "active"
      t.string "currency"
      t.string "email"
      t.string "phone"
      t.string "quotation", default: "new"
      t.string "reference"
    end
    create_table "promotions" do |t|
      t.string "name", null: false
      t.date "start_date", default: "2020-07-03", null: false
      t.date "end_date", default: "2020-07-03", null: false
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
    end
    create_table "referents" do |t|
      t.integer "referrer_id"
      t.integer "invited_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.decimal "commission"
    end
    create_table "role_permissions" do |t|
      t.bigint "role_id"
      t.bigint "permission_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
      t.index ["role_id"], name: "index_role_permissions_on_role_id"
    end
    create_table "roles" do |t|
      t.string "name"
      t.string "key"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "is_evo", default: false
    end
    create_table "salesmen" do |t|
      t.bigint "user_id"
      t.bigint "coordinator_id"
      t.decimal "sale_commission"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "active", default: false
      t.index ["coordinator_id"], name: "index_salesmen_on_coordinator_id"
      t.index ["user_id"], name: "index_salesmen_on_user_id"
    end
    create_table "settings" do |t|
      t.string "key"
      t.string "data_type"
      t.string "label"
      t.text "value"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "signers" do |t|
      t.string "name"
      t.string "definition"
      t.string "role"
      t.string "company"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "stage_promotions" do |t|
      t.bigint "promotion_id"
      t.bigint "stage_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["promotion_id"], name: "index_stage_promotions_on_promotion_id"
      t.index ["stage_id"], name: "index_stage_promotions_on_stage_id"
    end
    create_table "stage_sellers" do |t|
      t.bigint "stage_id"
      t.bigint "user_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["stage_id"], name: "index_stage_sellers_on_stage_id"
      t.index ["user_id"], name: "index_stage_sellers_on_user_id"
    end
    create_table "stages" do |t|
      t.string "rid"
      t.decimal "price"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "name"
      t.boolean "active", default: true
      t.integer "sold_lots", default: 0
      t.bigint "phase_id"
      t.bigint "enterprise_id"
      t.date "release_date"
      t.string "stage_type"
      t.decimal "min_down_payment"
      t.integer "order"
      t.decimal "initial_payment"
      t.integer "initial_payment_expiration"
      t.string "formula"
      t.integer "max_finance", default: 1
      t.integer "first_payment", default: 8
      t.string "reference"
      t.integer "down_payment_expiration"
      t.integer "lock_seller_period"
      t.integer "start_installments"
      t.decimal "min_capital_payment", default: "1.0"
      t.integer "payment_expiration", default: 7
      t.decimal "maintenance_fee"
      t.string "payment_email"
      t.decimal "lock_payment", default: "0.0"
      t.bigint "credit_scheme_id"
      t.index ["credit_scheme_id"], name: "index_stages_on_credit_scheme_id"
      t.index ["enterprise_id"], name: "index_stages_on_enterprise_id"
      t.index ["phase_id"], name: "index_stages_on_phase_id"
    end
    create_table "structures" do |t|
      t.bigint "role_id"
      t.bigint "user_id"
      t.integer "parent_id"
      t.decimal "sale_commission", default: "6.0"
      t.decimal "commission", default: "0.5"
      t.integer "max_branches", default: 5
      t.boolean "active", default: false
      t.string "before_key", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["role_id"], name: "index_structures_on_role_id"
      t.index ["user_id"], name: "index_structures_on_user_id"
    end
    create_table "users" do |t|
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
      t.string "rid"
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
      t.index ["branch_id"], name: "index_users_on_branch_id"
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
      t.index ["role_id"], name: "index_users_on_role_id"
    end
    create_table "vice_directors" do |t|
      t.bigint "user_id"
      t.bigint "director_id"
      t.decimal "commission"
      t.integer "max_branches"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "active", default: false
      t.decimal "sale_commission"
      t.index ["director_id"], name: "index_vice_directors_on_director_id"
      t.index ["user_id"], name: "index_vice_directors_on_user_id"
    end
    add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
    add_foreign_key "bank_accounts", "enterprises"
    add_foreign_key "base_commissions", "folders"
    add_foreign_key "base_commissions", "users"
    add_foreign_key "blueprint_lots", "blueprints"
    add_foreign_key "blueprint_lots", "lots"
    add_foreign_key "blueprints", "stages"
    add_foreign_key "clients", "users"
    add_foreign_key "comments", "folders"
    add_foreign_key "comments", "users"
    add_foreign_key "commissions", "base_commissions"
    add_foreign_key "commissions", "installments"
    add_foreign_key "contract_signers", "contracts"
    add_foreign_key "contract_signers", "signers"
    add_foreign_key "contracts", "projects"
    add_foreign_key "coordinators", "managers"
    add_foreign_key "coordinators", "users"
    add_foreign_key "directors", "users"
    add_foreign_key "evaluation_folders", "evaluations"
    add_foreign_key "evaluation_folders", "folders"
    add_foreign_key "evaluation_folders", "users"
    add_foreign_key "file_approvals", "users", column: "approved_by_id"
    add_foreign_key "folders", "clients"
    add_foreign_key "folders", "clients", column: "client_2_id"
    add_foreign_key "folders", "clients", column: "client_3_id"
    add_foreign_key "folders", "clients", column: "client_4_id"
    add_foreign_key "folders", "clients", column: "client_5_id"
    add_foreign_key "folders", "clients", column: "client_6_id"
    add_foreign_key "folders", "contracts"
    add_foreign_key "folders", "lots"
    add_foreign_key "folders", "users"
    add_foreign_key "installments", "folders"
    add_foreign_key "lots", "stages"
    add_foreign_key "managers", "users"
    add_foreign_key "managers", "vice_directors"
    add_foreign_key "moral_clients", "clients"
    add_foreign_key "payment_plans", "stages"
    add_foreign_key "payment_schemes", "credit_schemes"
    add_foreign_key "payment_schemes", "folders"
    add_foreign_key "payments", "bank_accounts"
    add_foreign_key "payments", "branches"
    add_foreign_key "payments", "clients"
    add_foreign_key "payments", "installments"
    add_foreign_key "payments", "payment_methods"
    add_foreign_key "payments", "users"
    add_foreign_key "periods", "credit_schemes"
    add_foreign_key "phases", "projects"
    add_foreign_key "physical_clients", "clients"
    add_foreign_key "project_sellers", "projects"
    add_foreign_key "project_sellers", "users"
    add_foreign_key "referents", "users", column: "invited_id"
    add_foreign_key "referents", "users", column: "referrer_id"
    add_foreign_key "role_permissions", "permissions"
    add_foreign_key "role_permissions", "roles"
    add_foreign_key "salesmen", "coordinators"
    add_foreign_key "salesmen", "users"
    add_foreign_key "stage_promotions", "promotions"
    add_foreign_key "stage_promotions", "stages"
    add_foreign_key "stage_sellers", "stages"
    add_foreign_key "stage_sellers", "users"
    add_foreign_key "stages", "credit_schemes"
    add_foreign_key "stages", "enterprises"
    add_foreign_key "stages", "phases"
    add_foreign_key "structures", "roles"
    add_foreign_key "structures", "users"
    add_foreign_key "users", "branches"
    add_foreign_key "users", "roles"
    add_foreign_key "users", "users", column: "created_by"
    add_foreign_key "vice_directors", "directors"
    add_foreign_key "vice_directors", "users"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
