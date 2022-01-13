# frozen_string_literal: true

class AddDocumentNomIdToDigitalSignatureServices < ActiveRecord::Migration[5.2]
  def change
    add_column :digital_signature_services, :document_nom_id, :integer
  end
end
