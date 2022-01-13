# frozen_string_literal: true

class TinyUpload < ApplicationRecord
  has_one_attached :file
  after_create :get_blob_name

  def get_blob_name
    self.update(key: self.file.filename.to_s)
  end
end
