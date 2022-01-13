# frozen_string_literal: true

namespace :delete_document do
  desc "Deletes every trace of a document from database"

  task imsure: :environment do
    # DOUBLE CHECK THE ID OF THE DOCUMENT YOU ARE GOING TO DELETE
    dt = DocumentTemplate.find()
    dt.documents.each do | d |
      if d.attached?
        d.file_versions.each do |fv|
          # fv.file.purge_later
          # fv.destroy!
        end
      end
      # d.destroy!
    end
    # dt.destroy!
  end
end
