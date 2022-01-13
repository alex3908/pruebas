# frozen_string_literal: true

json.partial! "api/v1/folders/active_payments", collection: @folders_payments, as: :folder_payment
