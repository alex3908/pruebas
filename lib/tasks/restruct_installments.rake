# frozen_string_literal: true

namespace :restruct_installments do
  desc "Run restruct installments task"

  task run: :environment do
    folders = [ 1421, 2540, 6130, 4098, 7417, 6151, 6754, 7416, 5496, 7418, 
    6196, 4366, 6194, 5728, 2876, 1544, 6195, 1543, 7419, 3857 ]

    Folder.where(id: folders).each do |folder|
      folder.payment_scheme.touch
    end
  end
end
  