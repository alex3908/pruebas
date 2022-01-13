# frozen_string_literal: true

namespace :lots do
  desc "Update the evo role levels"
  task for_sale: :environment do
    Lot.where.not(status: Lot::STATUS[:LOCKED_SALE]).update_all(status: Lot::STATUS[:FOR_SALE])
  end
end
