# frozen_string_literal: true

module DocumentsHelper
  def document_approved_tr_class(document)
    "table-danger" if document.file_approval.try(:rejected?)
  end

  def documents_action_statuses(documents)
    all = documents.inject(true) { |prev, current| prev && current.attached? }

    {
      any: documents.inject(false) { |prev, current| prev || current.attached? },
      all: all,
      none: !all
    }
  end
end
