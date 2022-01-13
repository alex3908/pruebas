# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Api::Engine => "/swagger"
  mount Rswag::Ui::Engine => "/api-docs"

  %w(404 500).each do |status_code|
    get status_code, to: "errors#show", status_code: status_code
  end

  get "disponibilidad", to: "availability#lots"
  get "cotizador/:slug_project/:slug_phase/:slug_stage", to: "availability#lots"
  get "cotizador/:slug_project/:slug_phase", to: "availability#lots"
  get "disponibilidad/:id", to: "availability#lot"
  get "disponibilidad/:id/cotizacion", to: "availability#quote", as: :quote_public
  post "disponibilidad/:id/cotizacion", to: "availability#send_quotation", as: :send_quotation
  post "disponibilidad/enviar-informacion", to: "availability#contact_information", as: :contact_information

  get "pago/exitoso", to: "payment_gateways#payment_success", as: :payment_success
  get "pagos/:reference", to: "payment_gateways#new", as: :new_online_payment
  post "pagos/:reference/create", to: "payment_gateways#create", as: :create_online_payment

  get "estado-de-cuenta/:folder_id", to: "installments#download_account_status", as: :download_account_status
  post "estado-de-cuenta/:folder_id/send", to: "installments#send_account_status", as: :send_account_status

  get "pagar/:id", to: "folders#pay_online", as: :folder_pay_online
  get "pagar/:id/concept_details", to: "folders#concept_details", as: :folder_concept_details
  post "pagar/:folder_id/with_service/:id", to: "online_payment_services#form", as: :online_payment_services_form

  get "subscribe/:folder_id/(/:client_id)", to: "subscriptions#new", as: :new_subscription
  post "subscribe/:folder_id", to: "subscriptions#create", as: :create_subscription
  put "subscribe/:folder_id", to: "subscriptions#update", as: :update_subscription

  get "success_password_recovery", to: "user_clients#success_recovery"

  resources :user_clients, only: :create do
    member do
      patch :recovery_password
    end
    collection do
      get :recovery_password, to: "user_clients#reset_password"
      put :update_password, to: "user_clients#update_password"
    end
  end

  resources :online_payment_tickets, only: :create do
    collection do
      post :export_xlsx
    end
    member do
      get :confirm
    end
  end

  resource :cash_flows do
    post :import
  end

  devise_for :users, controllers: { sessions: "sessions" }
  resource :reports do
    get :commissions
    get :folder_users
    get :overdue_balances
    get :file_approvals
    get :balances_close_to_due
    get :step
    get :delays
    get :additional_concept_payments
    get :commision_dispersion
    get :units
    get :folders

    get :future_cash_flow, to: "reports#future_cash_flow"
    post :future_cash_flow, to: "reports#future_cash_flow_request"
    get :online_payment_tickets, to: "reports#online_payment_tickets"
    post :online_payment_tickets, to: "reports#online_payment_tickets_request"
    get :payments, to: "reports#payments"
    post :payments, to: "reports#payments_request"
    get :clients, to: "reports#clients"
    post :clients, to: "reports#clients_request"
    get :users, to: "reports#users"
    post :users, to: "reports#users_request"
    get :users_kpi, to: "reports#users_kpi"
    post :users_kpi, to: "reports#users_kpi_request"
    get :quote_logs, to: "reports#quote_logs"
    post :quote_logs, to: "reports#quote_logs_request"
    get :referred_clients, to: "reports#referred_clients"
    post :referred_clients, to: "reports#referred_clients_request"
    get :referred_users, to: "reports#referred_users"
    post :referred_users, to: "reports#referred_users_request"
    get :sales, to: "reports#sales"
    post :sales, to: "reports#sales_request"
  end
  resource :status do
    get "pending", to: "status#pending"
  end
  resources :credit_schemes, except: [:show] do
    member do
      patch :change_status
      get :stages
      get :period_max_order
    end
    resources :discounts do
      member do
        patch :activate_plan
      end
    end
  end
  resources :transactions do
    member do
      get "checkout-reserve", to: "transactions#checkout_reserve"
      get "checkout-downpayment", to: "transactions#checkout_downpayment"
      get "execute-reserve", to: "transactions#execute_reserve"
      get "execute-downpayment", to: "transactions#execute_downpayment"
      get "error", to: "transactions#error"
    end
  end
  get "catalogs", to: "catalogs#index", as: :catalogs

  resources :permissions do
  end

  resources :steps do
    collection do
      get :pipeline, to: "steps#show_pipeline"
      post :export_historic
      post :export_average_times
      post :export_elapsed_times_per_folder
    end
    member do
      patch :toggle_block
      get :step_folders
    end
    resource :step_roles do
      member do
        patch ":step_role_id/allow/:document_id", to: "step_role#allow", as: "allow_downloadable"
      end
    end
  end

  resources :evaluations do
    member do
      patch "change_status", to: "evaluations#change_status"
    end
  end
  resources :settings
  resource :app_settings
  resources :structures, except: [:update, :edit] do
    collection do
      get "(:id)/subordinates", to: "structures#show", as: :subordinates
      get "(:id)/new_user", to: "structures#new_user", as: :new_user
      get "(:id)/unaffiliated_users", to: "structures#unaffiliated_users", as: :unaffiliated_users
      get "(:id)/level_settings", to: "structures#level_settings", as: :level_settings
      get :see_structure_tree
      get "(:id)/add_child_node", to: "structures#add_child_node", as: :add_child_node
      patch "(:id)/update_level/:role_id",  to: "structures#update_level", as: :update_level
      get "(:id)/replace_role/:role_id", to: "structures#replace_role", as: :replace_role
      get "(:id)/see_level_configurations_modal/:role_id", to: "structures#see_level_configurations_modal", as: :see_level_configurations_modal
      post "(:id)/set_child_node,", to: "structures#set_child_node", as: :set_child_node
      patch "(:id)/change_role/:role_id", to: "structures#change_role", as: :change_role
      get "get_subordinates/:user_id", to: "structures#get_subordinates", as: :get_subordinates
      post "(:id)/affiliated_user", to: "structures#affiliated_user", as: :affiliated_user
      post "(:id)/create_user", to: "structures#create_user", as: :create_user
      patch "(:id)/update_level_configurations/:role_id",  to: "structures#update_level_configurations", as: :update_level_configurations
    end
    member do
      patch :approve, to: "structures#approve", as: :approve
      delete :reject, to: "structures#reject", as: :reject
      patch :fire, to: "structures#fire", as: :fire
      patch :hire, to: "structures#hire", as: :hire
      get :prospects, to: "structures#prospects", as: :prospects
      get :information, to: "structures#information", as: :information
      delete :destroy, to: "structures#destroy", as: :destroy
      get :see_configuration, to: "structures#see_configuration", as: :see_configuration
      patch :update_configuration,  to: "structures#update_configuration", as: :update_configuration
      patch :resend_invitation, to: "structures#resend_invitation", as: :resend_invitation
      patch :reset_password, to: "structures#reset_password", as: :reset_password
    end
  end

  resources :lead_sources do
    member do
      patch "activate"
    end
  end

  resources :tags do
    member do
      patch "change_status", to: "tags#change_status"
    end
  end

  resources :identification_types
  resources :classifiers
  resources :payment_methods
  resources :commissions do
    collection do
      post :export_xlsx
      post :export
      post :import
      get :download
      post :export_dispersion
    end
    member do
      delete :remove_file
    end
  end
  resources :file_approvals, path: "file_approvals/(:type)", only: [:index] do
    member do
      patch "approve"
      patch "reject"
      get "rejectable_file", as: :rejectable
    end
    collection do
      post :export
    end
  end
  resources :signers
  resources :users, controller: "users" do
    patch "manage", to: "users#update"
    patch "activate_user", to: "users#activate_user"
    patch "resend_invitation", to: "users#resend_invitation"
    patch "reset_password", to: "users#reset_password"
    patch "approve_file", to: "users#approve_file", as: "approve_file"
    patch "reject_file", to: "users#reject_file"
    collection do
      get :referrals
      get "recovery", to: "users#recovery"
      get "exit", to: "users#exit", as: :exit_pretender
      post "manage", to: "users#create"
      get "assign_all", to: "users#assign_all", as: :assign_all
      get "deallocate_all", to: "users#deallocate_all", as: :deallocate_all
      get ":level/leaders", to: "users#get_leaders"
      patch "submit_documentation", to: "users#submit_documentation"
      delete "delete_bank_account", to: "users#delete_bank_account"
      delete "remove_file", to: "users#remove_file"
      get :autocomplete
    end
    member do
      get "become", to: "users#become", as: :pretender
      get "validate", to: "users#validate_user", as: "validate"
      get "rejectable_user_file", to: "users#rejectable_user_file", as: :rejectable_user_file
      delete :delete_suppression
      get :folders
    end
    resources :projects do
      patch "assignment", to: "users#assignment"
    end
    resources :stages do
      patch "assignment", to: "users#assignment_stage"
    end
    resources :bank_accounts do
      member do
        patch "change_status", to: "bank_accounts#change_status"
      end
    end
  end

  resources :roles do
    member do
      get "verify_reserve_status"
      get "classifiers"
    end
  end

  resource :payments, except: [:create, :edit, :update, :show, :destroy] do
    collection do
      post :export
      post :delays
    end
  end

  resources :folders do
    resources :comments, only: [:create, :show]
    resources :subscriptions, only: [:destroy] do
      member do
        put :invite_update
      end
      collection do
        get :invite
      end
    end
    resources :cash_flows do
      member do
        get :invoice
        patch "cancel", to: "cash_flows#cancel"
        get :see_cancel_modal
      end
    end
    resources :payments do
      member do
        get "invoice", to: "payments#invoice"
        patch "cancel", to: "payments#cancel"
        patch :resend_notification
        get :see_cancel_modal
      end
    end
    resource :installments do
      collection do
        get "custom_installments", to: "installments#custom_installments", as: :custom_installments
        patch "process_custom_installments", to: "installments#process_custom_installments", as: :process_custom_installments
        post "create_custom_installments", to: "installments#create_custom_installments", as: :create_custom_installments
      end
      member do
        get "payment", to: "installments#show", as: :payments
        get "account_status", to: "installments#account_status", as: :account_status
        get "mail_account_status", to: "installments#mail_account_status", as: :mail_account_status
        get "mail_payment_due_soon", to: "installments#mail_payment_due_soon", as: :mail_payment_due_soon
        post "payment", to: "installments#create", as: :create
      end
      collection do
        get :payment_settings
        get :payment_tabs_settings
        get :new_payment
        get :new_restructure
        get :new_additional_concept_payment
      end
      resource :penalties, only: [:new, :create, :update]
    end
    resources :support_sales, only: [:create, :update]
    collection do
      post :import
      post :export
      post :export_overdue_balances
      post :export_balances_close_to_due
    end
    member do
      get :pay_down_payment
      get :support_sale, to: "support_sales#show"
      get :change, to: "folders#change_quotation"
      get :annexe_1
      get :annexe_2
      get :annexe_3
      get :purchase_conditions
      get :deposit_format
      get :amortization_table
      get :amortization_cover
      get :down_payment_receipt
      get :purchase_promise_only
      get :purchase_promise_attached
      get :promissory_note
      post :purchase_promise
      patch :rejectable_file
      patch :toggle_reminders
      patch :extend
      patch :toggle_invoice

      post :add_client
      post "buyer/:buyer", to: "folders#change_buyer"

      patch "reject", to: "folders#reject"
      patch "soft_reject", to: "folders#soft_reject"
      patch "set_ready_state"
      patch "cancel", to: "folders#cancel"
      patch "accept", to: "folders#accept"
      patch :update_files
      patch "reassign_seller", to: "folders#reassign_seller", as: :reassign_seller
      patch "reassign_client", to: "folders#reassign_client", as: :reassign_client
      post "reactivate", to: "folders#reactivate", as: :reactivate
      delete "remove_file", to: "folders#remove_file"
      delete "client/:client/", to: "folders#remove_client"
      patch :force_approve
      patch :force_accepted
      post :send_purchase_promise_to_sign
      patch :cancel_purchase_promise_to_sign
      post :send_email_payment_link
      get :payment_modal_info
      get :sign_links_modal_info
      get :send_sign_link_email
    end
    resources :folder_users

    resources :documents, only: [:show] do
      member do
        patch :reject
        patch :approve
      end
    end
  end
  post :export_xlsx_folder_users, to: "folder_users#export_xlsx"
  resources :clients do
    member do
      post "create_additional", to: "clients#create_additional_by_json"
      patch :update_files
      patch "resend_email_confirmation", to: "clients#resend_email_confirmation"
      get "confirm_email", to: "clients#confirm_email"
      get :get_referred_clients
      delete :delete_suppression
    end
    collection do
      get :autocomplete
      get :autocomplete_by_email
      put :reassign, to: "clients#mass_reassign"
      post "validate_email", to: "clients#validate_email_json"
    end
    resources :cash_backs, except: [:index, :edit, :update, :show, :destroy] do
      member do
        patch :cancel
      end
    end
    resources :documents, only: [:show] do
      member do
        patch :reject
        patch :approve
      end
    end

    resources :referred_clients
  end
  resources :lots do
    member do
      patch "change_status", to: "lots#change_status"
    end
  end
  resources :enterprises do
    resources :online_payment_services
    resources :digital_signature_services
    resources :bank_accounts do
      member do
        patch :change_status
      end
    end
  end
  resources :branches do
    member do
      patch :change_status
    end
  end
  resources :projects do
    delete :remove_file
    collection do
      post :import
      post :export
    end
    resources :project_users

    collection do
      post :export_units
    end

    member do
      post :level_price
      put :status
    end
    resources :phases, except: [:index, :show, :destroy] do
      resources :blueprints, only: [] do
        resources :blueprint_stages, only: [:update]
      end
      resources :stages do
        member do
          delete :remove_file
          put :status
          get :imports
          patch :deallocate
        end
        collection do
          get :download_corrections
          get :show_stage_commission_schemes_roles
        end
        resources :lots, except: [:show] do
          resources :folders
          collection do
            post :import
            post :export
          end
          member do
            post :annexes
            patch :deallocate
            get "quote", to: "quotes#quote", as: :quote
            post "quote", to: "quotes#reserve", as: :reserve
            patch "lock", to: "lots#lock", as: :lock_lot
            delete :remove_file


            unless Rails.env.production?
              get :annexe_1
              get :annexe_2
              get :annexe_3
            end
          end
        end
        resources :blueprints, only: [] do
          member do
            patch :deallocate
          end
          resources :blueprint_lots, only: [:update]
        end
      end
    end
  end

  resources :promotions do
    resources :coupons do
      member do
        patch :activate
      end
    end

    member do
      patch :activate
      patch :activate_promotion
      patch :attributes_to_change
    end
  end

  resources :document_templates
  resources :document_sections
  resources :file_versions, only: [:destroy]
  resources :contracts do
    delete :remove_file
    collection do
      get :liquid_tags
    end
    member do
      get :preview
      patch :activate
      get :restore_annexe_order
      patch :update_custom_annexe_amount
    end
  end
  resources :email_templates do
    member do
      get :see_preview_modal
      post :send_preview_template
      delete :remove_file
    end
    collection do
      get :liquid_tags
    end
    resources :automated_emails do
      collection do
        get :show_inputs
      end
    end
  end
  resources :tiny_uploads, only: [:create]
  resources :job_statuses, except: [:destroy, :create, :update] do
    collection do
      get :read_logs
    end
    member do
      delete :cancel
    end
  end
  resources :folder_user_concepts do
    get :users
  end
  resources :additional_concepts do
    member do
      patch :change_status
      patch :activate
    end
  end

  resources :additional_concept_payments, only: [:index] do
    collection do
      post :export
    end
  end

  resources :sales, only: [:index]

  resources :commission_schemes, except: [:show]

  resources :imports, only: [:index] do
    collection do
      post :import_amortization_table
      post :import_cash_flow
      post :template_amortization_table
      post :template_cash_flow
      post :template_client_user
      post :import_client_user
      post :import_client
      get :download_import_template
      get :download_corrections
      post :import_corrections
      get :select_projects
      get :stages
      get :phases
      post :import_charges
      get :download_charges
      post :import_folders
      post :template_folder
    end
  end

  resources :client_user_concepts do
    collection do
      get :get_concepts
    end
  end

  resources :client_users, except: [:index] do
    collection do
      get "list_users_role/:id", to: "client_users#list_users_role", as: :list_users_role
      get "get_client_users/:client_id", to: "client_users#index", as: :get_client_users
    end
  end

  namespace :api do
    namespace :v1 do
      resources :sessions, only: [:create]
      resources :salesmen
      resources :payments, path: "generate", only: [:create]
      resources :folders, only: [:index] do
        resources :cash_flows, only: [:create]
        collection do
          get :folders_payments
          get :balances_close_to_due
          get :folders_information
        end
        member do
          post :cancel
          patch :upload_files
          get :folder_payments
          get :folder_balances_close_to_due
          get :folder_information
        end
      end
      resources :projects, only: [:index] do
        resources :phases, only: [:index] do
          resources :stages, only: [:index, :show] do
            member do
              get :blueprint
              get :annexe
            end
            resources :promotions, only: [:index]
            resources :discounts
            resources :lots, only: [:index, :show] do
              member do
                get :blueprint
                get :annexe
                get :map_annexe
                get :quote, to: "quotes#index", as: :quote
                post :reserve, to: "quotes#reserve", as: :reserve
              end
            end
          end
        end
      end
      resources :enterprises
      resources :clients, only: [:index, :show, :create] do
        member do
          patch :upload_files
        end
      end
      resources :attachments, only: [:index, :show]
    end
  end

  namespace :clients_api do
    namespace :v1 do
      resources :sessions, only: [:create] do
        collection do
          post :recovery_password
        end
      end
      get "clients/info", to: "clients#info"
      resources :clients, only: [:show] do
        collection do
          get :salesman
          get :documents
          get :responsible
          get "document/:document_template_id", to: "clients#document", as: :document
        end
      end

      resources :document_templates, only: [:index]

      resources :folders, only: [:index] do
        member do
          get :stp
          get "documents/:document_template_id", to: "folders#documents", as: :documents
          get :account_status
          get :pending_payments
          get :cash_flows
          get :get_invoice
          get :get_contract
          get :get_nom
          get "cash_flows/:cash_flow_id/invoice", to: "folders#invoice", as: :invoice
        end
      end
      resources :frequent_questions, only: [:index]

      resources :payment_methods, only: [:index]

      resources :payment_gateways, only: [:payment_info, :pay, :subscribe] do
        collection  do
          get "payment_info/folder/:folder_id", to: "payment_gateways#payment_info", as: :payment_info
          post "payment/folder/:folder_id", to: "payment_gateways#payment", as: :payment
          get "additional_services/folder/:folder_id", to: "payment_gateways#additional_services", as: :additional_services
        end
        post :suscribe
      end

      resources :users, only: [:customer_service] do
        collection do
          get "/customer_service/:folder_id", to: "users#customer_service", as: :customer_service
        end
      end
    end
  end
  resources :frequent_questions do
    member do
      patch :change_status
    end
  end

  namespace :webhook do
    post "online_payment_tickets/:provider", to: "online_payment_tickets#create"
    resources :clients, only: [:create]
    resources :subscriptions, only: [:create]
    resources :payments, only: :create
    resources :signature_services do
      collection do
        post :sign_event
      end
    end
  end

  if Rails.env.production?
    get "*all", to: "errors#render_404", constraints: lambda { |req|
      req.path.exclude? "rails/active_storage"
    }
  end

  root to: "dashboard#index"
end
