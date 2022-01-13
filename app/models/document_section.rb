# frozen_string_literal: true

class DocumentSection < ApplicationRecord
  include RailsSortable::Model
  set_sortable :order

  has_many :documents, dependent: :nullify
  has_many :document_templates, dependent: :nullify
end
