# frozen_string_literal: true

super_admin_role = Role.where(key: "superadmin", is_evo: false).first_or_create!(name: "Super Admin")
admin_role = Role.where(key: "admin", is_evo: false).first_or_create!(name: "Especialista en Proyectos")
project_manager_role = Role.where(key: "projectmanager", is_evo: false).first_or_create!(name: "Project Manager",)
treasurer_role = Role.where(key: "treasurer", is_evo: false).first_or_create!(name: "Tesorero")
support_role = Role.where(key: "support", is_evo: false).first_or_create!(name: "Atencio\u0301n a Clientes")
data_analyst_role = Role.where(key: "dataanalyst", is_evo: false).first_or_create!(name: "Analista de Datos")
director_role = Role.where(key: "director", is_evo: true, level: 0).first_or_create!(name: "Director")
vice_director_role = Role.where(key: "vice_director", is_evo: true, level: 1).first_or_create!(name: "Subdirector")
manager_role = Role.where(key: "manager", is_evo: true, level: 2).first_or_create!(name: "Gerente")
coordinator_role = Role.where(key: "coordinator", is_evo: true, level: 3).first_or_create!(name: "Coordinador")
realtor_role = Role.where(key: "realtor", is_evo: true, level: 5).first_or_create!(name: "Inmobiliaria")
salesman_role = Role.where(key: "salesman", is_evo: true, level: 4).first_or_create!(name: "Asesor")

create_role = Permission.find_by!(subject_class: "Role", action: "create")
read_role = Permission.find_by!(subject_class: "Role", action: "read")
update_role = Permission.find_by!(subject_class: "Role", action: "update")
permission_to = Permission.find_by!(subject_class: "Role", action: "permission_to")
view_hidden_role = Permission.find_by!(subject_class: "Role", action: "view_hidden")

create_project = Permission.find_by!(subject_class: "Project", action: "create")
read_project = Permission.find_by!(subject_class: "Project", action: "read")
update_project = Permission.find_by!(subject_class: "Project", action: "update")
change_status_project = Permission.find_by!(subject_class: "Project", action: "status")
sort_projects = Permission.find_by!(subject_class: "Project", action: "sort")

create_user = Permission.find_by!(subject_class: "User", action: "create")
read_user = Permission.find_by!(subject_class: "User", action: "read")
update_user = Permission.find_by!(subject_class: "User", action: "update")
assignment_user = Permission.find_by!(subject_class: "User", action: "assignment")
change_password_user = Permission.find_by!(subject_class: "User", action: "change_password")
activate_user = Permission.find_by!(subject_class: "User", action: "activate_user")
report_user = Permission.find_by!(subject_class: "User", action: "report")
become_user = Permission.find_by!(subject_class: "User", action: "become")
see_binnacle_user = Permission.find_by!(subject_class: "User", action: "see_binnacle")
see_sellers = Permission.find_by!(subject_class: "User", action: "see_sellers")
verify_user_file = Permission.find_by!(subject_class: "User", action: "verify_user_file")
update_referrer = Permission.find_by!(subject_class: "User", action: "update_referrer")
change_branch_user = Permission.find_by!(subject_class: "User", action: "change_branch")

create_stage = Permission.find_by!(subject_class: "Stage", action: "create")
read_stage = Permission.find_by!(subject_class: "Stage", action: "read")
update_stage = Permission.find_by!(subject_class: "Stage", action: "update")
status_stage = Permission.find_by!(subject_class: "Stage", action: "status")
sort_stages = Permission.find_by!(subject_class: "Stage", action: "sort")

create_phase = Permission.find_by!(subject_class: "Phase", action: "create")
read_phase = Permission.find_by!(subject_class: "Phase", action: "read")
update_phase = Permission.find_by!(subject_class: "Phase", action: "update")
sort_phases = Permission.find_by!(subject_class: "Phase", action: "sort")

create_lot = Permission.find_by!(subject_class: "Lot", action: "create")
read_lot = Permission.find_by!(subject_class: "Lot", action: "read")
update_lot = Permission.find_by!(subject_class: "Lot", action: "update")
destroy_lot = Permission.find_by!(subject_class: "Lot", action: "destroy")
lock_lot = Permission.find_by!(subject_class: "Lot", action: "lock")

create_client = Permission.find_by!(subject_class: "Client", action: "create")
read_client = Permission.find_by!(subject_class: "Client", action: "read")
update_client = Permission.find_by!(subject_class: "Client", action: "update")
see_binnacle_client = Permission.find_by!(subject_class: "Client", action: "see_binnacle")
rename_client = Permission.find_by!(subject_class: "Client", action: "rename")
edit_email_client = Permission.find_by!(subject_class: "Client", action: "edit_email")
import_client = Permission.find_by!(subject_class: "Client", action: "import")
mass_reassign_clients = Permission.find_by!(subject_class: "Client", action: "mass_reassign")

create_bank = Permission.find_by!(subject_class: "BankAccount", action: "create")
read_bank = Permission.find_by!(subject_class: "BankAccount", action: "read")
update_bank = Permission.find_by!(subject_class: "BankAccount", action: "update")

create_enterprise = Permission.find_by!(subject_class: "Enterprise", action: "create")
read_enterprise = Permission.find_by!(subject_class: "Enterprise", action: "read")
update_enterprise = Permission.find_by!(subject_class: "Enterprise", action: "update")

create_branch = Permission.find_by!(subject_class: "Branch", action: "create")
read_branch = Permission.find_by!(subject_class: "Branch", action: "read")
update_branch = Permission.find_by!(subject_class: "Branch", action: "update")

read_folder = Permission.find_by!(subject_class: "Folder", action: "read")
change_buyer = Permission.find_by!(subject_class: "Folder", action: "change_buyer")
see_binnacle = Permission.find_by!(subject_class: "Folder", action: "see_binnacle")
see_all = Permission.find_by!(subject_class: "Folder", action: "see_all")
read_sales_chart = Permission.find_by!(subject_class: "Folder", action: "read_sales_chart")
see_binnacle_folder = Permission.find_by!(subject_class: "Folder", action: "see_binnacle")
download_project_templates = Permission.find_by!(subject_class: "Folder", action: "download_templates")
reactivate = Permission.find_by!(subject_class: "Folder", action: "reactivate")
read_files_date = Permission.find_by!(subject_class: "Folder", action: "read_files_date")
request_support = Permission.find_by!(subject_class: "Folder", action: "request_support")
report = Permission.find_by!(subject_class: "Folder", action: "report")

create_contract = Permission.find_by!(subject_class: "Contract", action: "create")
read_contract = Permission.find_by!(subject_class: "Contract", action: "read")
update_contract = Permission.find_by!(subject_class: "Contract", action: "update")
destroy_contract = Permission.find_by!(subject_class: "Contract", action: "destroy")
see_binnacle_contract = Permission.find_by!(subject_class: "Contract", action: "see_binnacle")
create_custom_purchase_promise = Permission.find_by!(subject_class: "Contract", action: "custom_create")
update_custom_purchase_promise = Permission.find_by!(subject_class: "Contract", action: "custom_update")
delete_custom_purchase_promise = Permission.find_by!(subject_class: "Contract", action: "custom_destroy")
index_custom_purchase_promise = Permission.find_by!(subject_class: "Contract", action: "custom_index")

quote = Permission.find_by!(subject_class: ":quote", action: "quote")
reserve = Permission.find_by!(subject_class: ":quote", action: "reserve")
custom_discount = Permission.find_by!(subject_class: ":quote", action: "custom_discount")
custom_buy_price = Permission.find_by!(subject_class: ":quote", action: "custom_buy_price")
custom_zero_rate = Permission.find_by!(subject_class: ":quote", action: "custom_zero_rate")
custom_start_installments = Permission.find_by!(subject_class: ":quote", action: "custom_start_installments")
custom_promotion = Permission.find_by!(subject_class: ":quote", action: "custom_promotion")
custom_credit = Permission.find_by!(subject_class: ":quote", action: "custom_credit")
custom_first_payment = Permission.find_by!(subject_class: ":quote", action: "custom_first_payment")
custom_down_payment_finance = Permission.find_by!(subject_class: ":quote", action: "custom_down_payment_finance")
custom_down_payment_amount = Permission.find_by!(subject_class: ":quote", action: "custom_down_payment_amount")
custom_initial_payment = Permission.find_by!(subject_class: ":quote", action: "custom_initial_payment")
custom_start_date = Permission.find_by!(subject_class: ":quote", action: "custom_start_date")

read_payment = Permission.find_by!(subject_class: "CashFlow", action: "read")

create_payment_method = Permission.find_by!(subject_class: "PaymentMethod", action: "create")
read_payment_method = Permission.find_by!(subject_class: "PaymentMethod", action: "read")
update_payment_method = Permission.find_by!(subject_class: "PaymentMethod", action: "update")

read_commission = Permission.find_by!(subject_class: "Commission", action: "read")
update_commission = Permission.find_by!(subject_class: "Commission", action: "update")
import_commission = Permission.find_by!(subject_class: "Commission", action: "import")

approve_teams = Permission.find_by!(subject_class: "Structure", action: "approval")

show_structures = Permission.find_by!(subject_class: "Structure", action: "read")
hire_and_fire_structures = Permission.find_by(subject_class: "Structure", action: "hire_and_fire")
destroy_structures = Permission.find_by(subject_class: "Structure", action: "destroy")

set_date_role = Permission.find_by!(subject_class: "Installment", action: "set_date")
create_installment = Permission.find_by!(subject_class: "Installment", action: "create")
account_status_installment = Permission.find_by!(subject_class: "Installment", action: "account_status")
new_payment_installment = Permission.find_by!(subject_class: "Installment", action: "new_payment")
new_capital_installment = Permission.find_by!(subject_class: "Installment", action: "new_capital")
new_restructure_installment = Permission.find_by!(subject_class: "Installment", action: "new_restructure")
new_date_installment = Permission.find_by!(subject_class: "Installment", action: "new_date")
mail_payment_due_soon = Permission.find_by!(subject_class: "Installment", action: "mail_payment_due_soon")

read_setting = Permission.find_by!(subject_class: "Setting", action: "read")
update_setting = Permission.find_by!(subject_class: "Setting", action: "update")

read_promotion = Permission.find_by!(subject_class: "Promotion", action: "read")
create_promotion = Permission.find_by!(subject_class: "Promotion", action: "create")
update_promotion = Permission.find_by!(subject_class: "Promotion", action: "update")
delete_promotion = Permission.find_by!(subject_class: "Promotion", action: "destroy")
activate_promotion = Permission.find_by!(subject_class: "Promotion", action: "activate_promotion")

create_permission = Permission.find_by!(subject_class: "Permission", action: "create")
read_permission = Permission.find_by!(subject_class: "Permission", action: "read")
update_permission = Permission.find_by!(subject_class: "Permission", action: "update")
destroy_permission = Permission.find_by!(subject_class: "Permission", action: "destroy")
view_hidden_permission = Permission.find_by!(subject_class: "Permission", action: "view_hidden")

create_evaluation = Permission.find_by!(subject_class: "Evaluation", action: "create")
read_evaluation = Permission.find_by!(subject_class: "Evaluation", action: "read")
update_evaluation = Permission.find_by!(subject_class: "Evaluation", action: "update")
destroy_evaluation = Permission.find_by!(subject_class: "Evaluation", action: "destroy")

read_signer = Permission.find_by!(subject_class: "Signer", action: "read")
create_signer = Permission.find_by!(subject_class: "Signer", action: "create")
update_signer = Permission.find_by!(subject_class: "Signer", action: "update")
delete_signer = Permission.find_by!(subject_class: "Signer", action: "destroy")

read_lead_source = Permission.find_by!(subject_class: "LeadSource", action: "read")
create_lead_source = Permission.find_by!(subject_class: "LeadSource", action: "create")
update_lead_source = Permission.find_by!(subject_class: "LeadSource", action: "update")
activate_lead_source = Permission.find_by!(subject_class: "LeadSource", action: "activate")
destroy_lead_source = Permission.find_by!(subject_class: "LeadSource", action: "destroy")

create_credit_scheme = Permission.find_by!(subject_class: "CreditScheme", action: "create")
read_credit_scheme = Permission.find_by!(subject_class: "CreditScheme", action: "read")
update_credit_scheme = Permission.find_by!(subject_class: "CreditScheme", action: "update")
destroy_credit_scheme = Permission.find_by!(subject_class: "CreditScheme", action: "destroy")
change_status_credit_scheme = Permission.find_by!(subject_class: "CreditScheme", action: "change_status")

create_tag = Permission.find_by!(subject_class: "Tag", action: "create")
read_tag = Permission.find_by!(subject_class: "Tag", action: "read")
update_tag = Permission.find_by!(subject_class: "Tag", action: "update")
destroy_tag = Permission.find_by!(subject_class: "Tag", action: "destroy")
change_status_tag = Permission.find_by!(subject_class: "Tag", action: "change_status")

create_step = Permission.find_by!(subject_class: "Step", action: "create")
read_step = Permission.find_by!(subject_class: "Step", action: "read")
update_step = Permission.find_by!(subject_class: "Step", action: "update")
destroy_step = Permission.find_by!(subject_class: "Step", action: "destroy")
read_step_log = Permission.find_by!(subject_class: "Step", action: "read_step_log")
block_step = Permission.find_by!(subject_class: "Step", action: "block")

create_document_template = Permission.find_by!(subject_class: "DocumentTemplate", action: "create")
read_document_template = Permission.find_by!(subject_class: "DocumentTemplate", action: "read")
update_document_template = Permission.find_by!(subject_class: "DocumentTemplate", action: "update")
destroy_document_template = Permission.find_by!(subject_class: "DocumentTemplate", action: "destroy")
sort_document_template = Permission.find_by!(subject_class: "DocumentTemplate", action: "sort")

create_document_section = Permission.find_by!(subject_class: "DocumentSection", action: "create")
read_document_section = Permission.find_by!(subject_class: "DocumentSection", action: "read")
update_document_section = Permission.find_by!(subject_class: "DocumentSection", action: "update")
destroy_document_section = Permission.find_by!(subject_class: "DocumentSection", action: "destroy")
sort_document_section = Permission.find_by!(subject_class: "DocumentSection", action: "sort")

create_penalty = Permission.find_by!(subject_class: "Penalty", action: "create")
remove_penalty = Permission.find_by!(subject_class: "Penalty", action: "update")

see_binnacle_support_sale = Permission.find_by!(subject_class: "SupportSale", action: "see_binnacle")

create_coupon = Permission.find_by!(subject_class: "Coupon", action: "create")
read_coupon = Permission.find_by!(subject_class: "Coupon", action: "read")
update_coupon = Permission.find_by!(subject_class: "Coupon", action: "update")
destroy_coupon = Permission.find_by!(subject_class: "Coupon", action: "destroy")
activate_coupon = Permission.find_by!(subject_class: "Coupon", action: "activate")

create_online_payment_service = Permission.find_by!(subject_class: "OnlinePaymentService", action: "create")
update_online_payment_service = Permission.find_by!(subject_class: "OnlinePaymentService", action: "update")
destroy_online_payment_service = Permission.find_by!(subject_class: "OnlinePaymentService", action: "destroy")

create_commission_scheme = Permission.find_by!(subject_class: "CommissionScheme", action: "create")
read_commission_scheme = Permission.find_by!(subject_class: "CommissionScheme", action: "read")
update_commission_scheme = Permission.find_by!(subject_class: "CommissionScheme", action: "update")
destroy_commission_scheme = Permission.find_by!(subject_class: "CommissionScheme", action: "destroy")

read_logs_job_status = Permission.find_by!(subject_class: "JobStatus", action: "read_logs")

create_classifier = Permission.find_by!(subject_class: "Classifier", action: "create")
update_classifier = Permission.find_by!(subject_class: "Classifier", action: "update")
read_classifier = Permission.find_by!(subject_class: "Classifier", action: "read")

# Permissions of the super admin role
RolePermission.where(role: super_admin_role, permission: see_binnacle_support_sale).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_role).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_role).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_role).first_or_create!
RolePermission.where(role: super_admin_role, permission: permission_to).first_or_create!
RolePermission.where(role: super_admin_role, permission: view_hidden_role).first_or_create!
RolePermission.where(role: super_admin_role, permission: change_password_user).first_or_create!
RolePermission.where(role: super_admin_role, permission: activate_user).first_or_create!
RolePermission.where(role: super_admin_role, permission: report_user).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_project).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_project).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_project).first_or_create!
RolePermission.where(role: super_admin_role, permission: change_status_project).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_phase).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_phase).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_phase).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_stage).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_stage).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_stage).first_or_create!
RolePermission.where(role: super_admin_role, permission: status_stage).first_or_create!
RolePermission.where(role: super_admin_role, permission: quote).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_bank).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_bank).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_bank).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_enterprise).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_enterprise).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_enterprise).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_user).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_user).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_user).first_or_create!
RolePermission.where(role: super_admin_role, permission: assignment_user).first_or_create!
RolePermission.where(role: super_admin_role, permission: become_user).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_setting).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_setting).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_branch).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_branch).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_branch).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_folder).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_client).first_or_create!
RolePermission.where(role: super_admin_role, permission: import_client).first_or_create!
RolePermission.where(role: super_admin_role, permission: mass_reassign_clients).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_client).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_client).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_sales_chart).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_payment_method).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_payment_method).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_payment_method).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_commission).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_commission).first_or_create!
RolePermission.where(role: super_admin_role, permission: import_commission).first_or_create!
RolePermission.where(role: super_admin_role, permission: approve_teams).first_or_create!
RolePermission.where(role: super_admin_role, permission: set_date_role).first_or_create!
RolePermission.where(role: super_admin_role, permission: change_password_user).first_or_create!
RolePermission.where(role: super_admin_role, permission: activate_user).first_or_create!
RolePermission.where(role: super_admin_role, permission: report_user).first_or_create!
RolePermission.where(role: super_admin_role, permission: change_buyer).first_or_create!
RolePermission.where(role: super_admin_role, permission: see_all).first_or_create!
RolePermission.where(role: super_admin_role, permission: see_binnacle).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_contract).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_contract).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_contract).first_or_create!
RolePermission.where(role: super_admin_role, permission: destroy_contract).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_installment).first_or_create!
RolePermission.where(role: super_admin_role, permission: account_status_installment).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_payment).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_lot).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_lot).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_lot).first_or_create!
RolePermission.where(role: super_admin_role, permission: destroy_lot).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_promotion).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_promotion).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_promotion).first_or_create!
RolePermission.where(role: super_admin_role, permission: delete_promotion).first_or_create!
RolePermission.where(role: super_admin_role, permission: activate_promotion).first_or_create!
RolePermission.where(role: super_admin_role, permission: see_binnacle_user).first_or_create!
RolePermission.where(role: super_admin_role, permission: see_binnacle_contract).first_or_create!
RolePermission.where(role: super_admin_role, permission: download_project_templates).first_or_create!
RolePermission.where(role: super_admin_role, permission: reactivate).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_signer).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_signer).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_signer).first_or_create!
RolePermission.where(role: super_admin_role, permission: delete_signer).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_evaluation).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_evaluation).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_evaluation).first_or_create!
RolePermission.where(role: super_admin_role, permission: destroy_evaluation).first_or_create!
RolePermission.where(role: super_admin_role, permission: show_structures).first_or_create!
RolePermission.where(role: super_admin_role, permission: hire_and_fire_structures).first_or_create!
RolePermission.where(role: super_admin_role, permission: destroy_structures).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_permission).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_permission).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_permission).first_or_create!
RolePermission.where(role: super_admin_role, permission: destroy_permission).first_or_create!
RolePermission.where(role: super_admin_role, permission: view_hidden_permission).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_files_date).first_or_create!
RolePermission.where(role: super_admin_role, permission: verify_user_file).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_files_date).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_lead_source).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_lead_source).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_lead_source).first_or_create!
RolePermission.where(role: super_admin_role, permission: activate_lead_source).first_or_create!
RolePermission.where(role: super_admin_role, permission: destroy_lead_source).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_credit_scheme).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_credit_scheme).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_credit_scheme).first_or_create!
RolePermission.where(role: super_admin_role, permission: destroy_credit_scheme).first_or_create!
RolePermission.where(role: super_admin_role, permission: change_status_credit_scheme).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_tag).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_tag).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_tag).first_or_create!
RolePermission.where(role: super_admin_role, permission: destroy_tag).first_or_create!
RolePermission.where(role: super_admin_role, permission: change_status_tag).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_custom_purchase_promise).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_custom_purchase_promise).first_or_create!
RolePermission.where(role: super_admin_role, permission: delete_custom_purchase_promise).first_or_create!
RolePermission.where(role: super_admin_role, permission: index_custom_purchase_promise).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_referrer).first_or_create!
RolePermission.where(role: super_admin_role, permission: sort_phases).first_or_create!
RolePermission.where(role: super_admin_role, permission: sort_projects).first_or_create!
RolePermission.where(role: super_admin_role, permission: sort_stages).first_or_create!
RolePermission.where(role: super_admin_role, permission: custom_discount).first_or_create!
RolePermission.where(role: super_admin_role, permission: custom_buy_price).first_or_create!
RolePermission.where(role: super_admin_role, permission: custom_zero_rate).first_or_create!
RolePermission.where(role: super_admin_role, permission: custom_start_installments).first_or_create!
RolePermission.where(role: super_admin_role, permission: custom_promotion).first_or_create!
RolePermission.where(role: super_admin_role, permission: custom_credit).first_or_create!
RolePermission.where(role: super_admin_role, permission: custom_first_payment).first_or_create!
RolePermission.where(role: super_admin_role, permission: custom_down_payment_finance).first_or_create!
RolePermission.where(role: super_admin_role, permission: custom_down_payment_amount).first_or_create!
RolePermission.where(role: super_admin_role, permission: custom_initial_payment).first_or_create!
RolePermission.where(role: super_admin_role, permission: custom_start_date).first_or_create!
RolePermission.where(role: super_admin_role, permission: new_payment_installment).first_or_create!
RolePermission.where(role: super_admin_role, permission: new_capital_installment).first_or_create!
RolePermission.where(role: super_admin_role, permission: new_restructure_installment).first_or_create!
RolePermission.where(role: super_admin_role, permission: new_date_installment).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_step).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_step).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_step).first_or_create!
RolePermission.where(role: super_admin_role, permission: destroy_step).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_step_log).first_or_create!
RolePermission.where(role: super_admin_role, permission: block_step).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_document_template).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_document_template).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_document_template).first_or_create!
RolePermission.where(role: super_admin_role, permission: destroy_document_template).first_or_create!
RolePermission.where(role: super_admin_role, permission: sort_document_template).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_document_section).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_document_section).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_document_section).first_or_create!
RolePermission.where(role: super_admin_role, permission: destroy_document_section).first_or_create!
RolePermission.where(role: super_admin_role, permission: sort_document_section).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_penalty).first_or_create!
RolePermission.where(role: super_admin_role, permission: remove_penalty).first_or_create!
RolePermission.where(role: super_admin_role, permission: create_coupon).first_or_create
RolePermission.where(role: super_admin_role, permission: read_coupon).first_or_create
RolePermission.where(role: super_admin_role, permission: update_coupon).first_or_create
RolePermission.where(role: super_admin_role, permission: destroy_coupon).first_or_create
RolePermission.where(role: super_admin_role, permission: activate_coupon).first_or_create
RolePermission.where(role: super_admin_role, permission: create_online_payment_service).first_or_create
RolePermission.where(role: super_admin_role, permission: update_online_payment_service).first_or_create
RolePermission.where(role: super_admin_role, permission: destroy_online_payment_service).first_or_create
RolePermission.where(role: super_admin_role, permission: create_commission_scheme).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_commission_scheme).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_commission_scheme).first_or_create!
RolePermission.where(role: super_admin_role, permission: destroy_commission_scheme).first_or_create!
RolePermission.where(role: super_admin_role, permission: report).first_or_create!
RolePermission.where(role: super_admin_role, permission: mail_payment_due_soon).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_logs_job_status).first_or_create!
RolePermission.where(role: super_admin_role, permission: change_branch_user).first_or_create!

RolePermission.where(role: super_admin_role, permission: create_classifier).first_or_create!
RolePermission.where(role: super_admin_role, permission: read_classifier).first_or_create!
RolePermission.where(role: super_admin_role, permission: update_classifier).first_or_create!

# Permissions of the admin role
RolePermission.where(role: admin_role, permission: create_project).first_or_create!
RolePermission.where(role: admin_role, permission: read_project).first_or_create!
RolePermission.where(role: admin_role, permission: update_project).first_or_create!
RolePermission.where(role: admin_role, permission: create_phase).first_or_create!
RolePermission.where(role: admin_role, permission: read_phase).first_or_create!
RolePermission.where(role: admin_role, permission: update_phase).first_or_create!
RolePermission.where(role: admin_role, permission: create_stage).first_or_create!
RolePermission.where(role: admin_role, permission: read_stage).first_or_create!
RolePermission.where(role: admin_role, permission: update_stage).first_or_create!
RolePermission.where(role: admin_role, permission: status_stage).first_or_create!
RolePermission.where(role: admin_role, permission: create_lot).first_or_create!
RolePermission.where(role: admin_role, permission: read_lot).first_or_create!
RolePermission.where(role: admin_role, permission: update_lot).first_or_create!
RolePermission.where(role: admin_role, permission: destroy_lot).first_or_create!
RolePermission.where(role: admin_role, permission: quote).first_or_create!
RolePermission.where(role: admin_role, permission: create_bank).first_or_create!
RolePermission.where(role: admin_role, permission: read_bank).first_or_create!
RolePermission.where(role: admin_role, permission: update_bank).first_or_create!
RolePermission.where(role: admin_role, permission: create_enterprise).first_or_create!
RolePermission.where(role: admin_role, permission: read_enterprise).first_or_create!
RolePermission.where(role: admin_role, permission: update_enterprise).first_or_create!
RolePermission.where(role: admin_role, permission: read_contract).first_or_create!
RolePermission.where(role: admin_role, permission: update_contract).first_or_create!
RolePermission.where(role: admin_role, permission: lock_lot).first_or_create!
RolePermission.where(role: admin_role, permission: create_document_template).first_or_create!
RolePermission.where(role: admin_role, permission: read_document_template).first_or_create!
RolePermission.where(role: admin_role, permission: update_document_template).first_or_create!
RolePermission.where(role: admin_role, permission: destroy_document_template).first_or_create!
RolePermission.where(role: admin_role, permission: sort_document_template).first_or_create!
RolePermission.where(role: admin_role, permission: create_document_section).first_or_create!
RolePermission.where(role: admin_role, permission: read_document_section).first_or_create!
RolePermission.where(role: admin_role, permission: update_document_section).first_or_create!
RolePermission.where(role: admin_role, permission: destroy_document_section).first_or_create!
RolePermission.where(role: admin_role, permission: sort_document_section).first_or_create!


# Permissions of the project manager role
RolePermission.where(role: project_manager_role, permission: read_project).first_or_create!
RolePermission.where(role: project_manager_role, permission: read_phase).first_or_create!
RolePermission.where(role: project_manager_role, permission: read_stage).first_or_create!
RolePermission.where(role: project_manager_role, permission: read_lot).first_or_create!
RolePermission.where(role: project_manager_role, permission: quote).first_or_create!
RolePermission.where(role: project_manager_role, permission: create_bank).first_or_create!
RolePermission.where(role: project_manager_role, permission: read_bank).first_or_create!
RolePermission.where(role: project_manager_role, permission: update_bank).first_or_create!
RolePermission.where(role: project_manager_role, permission: create_enterprise).first_or_create!
RolePermission.where(role: project_manager_role, permission: read_enterprise).first_or_create!
RolePermission.where(role: project_manager_role, permission: update_enterprise).first_or_create!
RolePermission.where(role: project_manager_role, permission: create_user).first_or_create!
RolePermission.where(role: project_manager_role, permission: read_user).first_or_create!
RolePermission.where(role: project_manager_role, permission: update_user).first_or_create!
RolePermission.where(role: project_manager_role, permission: assignment_user).first_or_create!
RolePermission.where(role: project_manager_role, permission: create_branch).first_or_create!
RolePermission.where(role: project_manager_role, permission: read_branch).first_or_create!
RolePermission.where(role: project_manager_role, permission: update_branch).first_or_create!
RolePermission.where(role: project_manager_role, permission: change_buyer).first_or_create!
RolePermission.where(role: project_manager_role, permission: see_binnacle).first_or_create!
RolePermission.where(role: project_manager_role, permission: see_all).first_or_create!
RolePermission.where(role: project_manager_role, permission: create_client).first_or_create!
RolePermission.where(role: project_manager_role, permission: read_client).first_or_create!
RolePermission.where(role: project_manager_role, permission: update_client).first_or_create!
RolePermission.where(role: project_manager_role, permission: see_binnacle_client).first_or_create!
RolePermission.where(role: project_manager_role, permission: rename_client).first_or_create!
RolePermission.where(role: project_manager_role, permission: edit_email_client).first_or_create!
RolePermission.where(role: project_manager_role, permission: read_folder).first_or_create!
RolePermission.where(role: project_manager_role, permission: see_sellers).first_or_create!

# Permissions of the salesman role
RolePermission.where(role: salesman_role, permission: read_folder).first_or_create!
RolePermission.where(role: salesman_role, permission: read_project).first_or_create!
RolePermission.where(role: salesman_role, permission: read_phase).first_or_create!
RolePermission.where(role: salesman_role, permission: read_stage).first_or_create!
RolePermission.where(role: salesman_role, permission: update_lot).first_or_create!
RolePermission.where(role: salesman_role, permission: quote).first_or_create!
RolePermission.where(role: salesman_role, permission: reserve).first_or_create!
RolePermission.where(role: salesman_role, permission: change_buyer).first_or_create!
RolePermission.where(role: salesman_role, permission: create_client).first_or_create!
RolePermission.where(role: salesman_role, permission: read_client).first_or_create!
RolePermission.where(role: salesman_role, permission: update_client).first_or_create!
RolePermission.where(role: salesman_role, permission: read_commission).first_or_create!
RolePermission.where(role: salesman_role, permission: request_support).first_or_create!

# Permissions of the treasurer role
RolePermission.where(role: treasurer_role, permission: quote).first_or_create!
RolePermission.where(role: treasurer_role, permission: read_folder).first_or_create!
RolePermission.where(role: treasurer_role, permission: change_buyer).first_or_create!

# Permissions of the support role
RolePermission.where(role: support_role, permission: read_folder).first_or_create!
RolePermission.where(role: support_role, permission: create_client).first_or_create!
RolePermission.where(role: support_role, permission: read_client).first_or_create!
RolePermission.where(role: support_role, permission: update_client).first_or_create!

# Permissions of the data_analyst role
RolePermission.where(role: data_analyst_role, permission: read_folder).first_or_create!
RolePermission.where(role: data_analyst_role, permission: see_all).first_or_create!
RolePermission.where(role: data_analyst_role, permission: read_project).first_or_create!

# Permissions of the director role
RolePermission.where(role: director_role, permission: read_project).first_or_create!
RolePermission.where(role: director_role, permission: read_phase).first_or_create!
RolePermission.where(role: director_role, permission: read_stage).first_or_create!
RolePermission.where(role: director_role, permission: quote).first_or_create!
RolePermission.where(role: director_role, permission: approve_teams).first_or_create!

# Permissions of the vice director role
RolePermission.where(role: vice_director_role, permission: read_folder).first_or_create!
RolePermission.where(role: vice_director_role, permission: read_project).first_or_create!
RolePermission.where(role: vice_director_role, permission: read_phase).first_or_create!
RolePermission.where(role: vice_director_role, permission: read_stage).first_or_create!
RolePermission.where(role: vice_director_role, permission: update_lot).first_or_create!
RolePermission.where(role: vice_director_role, permission: quote).first_or_create!
RolePermission.where(role: vice_director_role, permission: reserve).first_or_create!
RolePermission.where(role: vice_director_role, permission: change_buyer).first_or_create!
RolePermission.where(role: vice_director_role, permission: create_client).first_or_create!
RolePermission.where(role: vice_director_role, permission: read_client).first_or_create!
RolePermission.where(role: vice_director_role, permission: update_client).first_or_create!
RolePermission.where(role: vice_director_role, permission: see_binnacle_client).first_or_create!
RolePermission.where(role: vice_director_role, permission: create_user).first_or_create!
RolePermission.where(role: vice_director_role, permission: read_user).first_or_create!
RolePermission.where(role: vice_director_role, permission: update_user).first_or_create!
RolePermission.where(role: vice_director_role, permission: report_user).first_or_create!
RolePermission.where(role: vice_director_role, permission: see_binnacle_user).first_or_create!
RolePermission.where(role: vice_director_role, permission: see_binnacle_folder).first_or_create!
RolePermission.where(role: vice_director_role, permission: approve_teams).first_or_create!

# Permissions of the manager role
RolePermission.where(role: manager_role, permission: read_folder).first_or_create!
RolePermission.where(role: manager_role, permission: read_project).first_or_create!
RolePermission.where(role: manager_role, permission: read_phase).first_or_create!
RolePermission.where(role: manager_role, permission: read_stage).first_or_create!
RolePermission.where(role: manager_role, permission: update_lot).first_or_create!
RolePermission.where(role: manager_role, permission: quote).first_or_create!
RolePermission.where(role: manager_role, permission: reserve).first_or_create!
RolePermission.where(role: manager_role, permission: change_buyer).first_or_create!
RolePermission.where(role: manager_role, permission: create_client).first_or_create!
RolePermission.where(role: manager_role, permission: read_client).first_or_create!
RolePermission.where(role: manager_role, permission: update_client).first_or_create!
RolePermission.where(role: manager_role, permission: see_binnacle_client).first_or_create!
RolePermission.where(role: manager_role, permission: create_user).first_or_create!
RolePermission.where(role: manager_role, permission: read_user).first_or_create!
RolePermission.where(role: manager_role, permission: update_user).first_or_create!
RolePermission.where(role: manager_role, permission: report_user).first_or_create!
RolePermission.where(role: manager_role, permission: see_binnacle_user).first_or_create!
RolePermission.where(role: manager_role, permission: see_binnacle_folder).first_or_create!
RolePermission.where(role: manager_role, permission: approve_teams).first_or_create!

# Permissions of the coordinator role
RolePermission.where(role: coordinator_role, permission: read_folder).first_or_create!
RolePermission.where(role: coordinator_role, permission: read_project).first_or_create!
RolePermission.where(role: coordinator_role, permission: read_phase).first_or_create!
RolePermission.where(role: coordinator_role, permission: read_stage).first_or_create!
RolePermission.where(role: coordinator_role, permission: update_lot).first_or_create!
RolePermission.where(role: coordinator_role, permission: quote).first_or_create!
RolePermission.where(role: coordinator_role, permission: reserve).first_or_create!
RolePermission.where(role: coordinator_role, permission: change_buyer).first_or_create!
RolePermission.where(role: coordinator_role, permission: create_client).first_or_create!
RolePermission.where(role: coordinator_role, permission: read_client).first_or_create!
RolePermission.where(role: coordinator_role, permission: update_client).first_or_create!
RolePermission.where(role: coordinator_role, permission: see_binnacle_client).first_or_create!
RolePermission.where(role: coordinator_role, permission: create_user).first_or_create!
RolePermission.where(role: coordinator_role, permission: read_user).first_or_create!
RolePermission.where(role: coordinator_role, permission: update_user).first_or_create!
RolePermission.where(role: coordinator_role, permission: report_user).first_or_create!
RolePermission.where(role: coordinator_role, permission: see_binnacle_user).first_or_create!
RolePermission.where(role: coordinator_role, permission: see_binnacle_folder).first_or_create!

# Permissions of the realtor role
RolePermission.where(role: realtor_role, permission: read_folder).first_or_create!
RolePermission.where(role: realtor_role, permission: read_project).first_or_create!
RolePermission.where(role: realtor_role, permission: read_phase).first_or_create!
RolePermission.where(role: realtor_role, permission: read_stage).first_or_create!
RolePermission.where(role: realtor_role, permission: update_lot).first_or_create!
RolePermission.where(role: realtor_role, permission: quote).first_or_create!
RolePermission.where(role: realtor_role, permission: reserve).first_or_create!
RolePermission.where(role: realtor_role, permission: change_buyer).first_or_create!
RolePermission.where(role: realtor_role, permission: create_client).first_or_create!
RolePermission.where(role: realtor_role, permission: read_client).first_or_create!
RolePermission.where(role: realtor_role, permission: update_client).first_or_create!
