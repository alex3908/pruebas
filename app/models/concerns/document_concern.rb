# frozen_string_literal: true

module DocumentConcern
  extend ActiveSupport::Concern

  def document_by_template_id(document_template_id)
    documents.find_by!(document_template_id: document_template_id)
  end
end
