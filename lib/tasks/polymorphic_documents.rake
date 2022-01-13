# frozen_string_literal: true

namespace :polymorphic_documents do
  desc "Updates documents table to new polymorphic relation"

  task run: :environment do
    Document.all.each do |document|
      document.update(documentable_type: "Folder", documentable_id: document.folder_id)
    end
  end
end
