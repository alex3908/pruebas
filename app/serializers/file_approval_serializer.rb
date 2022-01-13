# frozen_string_literal: true

class FileApprovalSerializer < ActiveModel::Serializer
  attributes :id, :approved_at, :key
  has_one :folder
  has_one :approved_by
end
