# frozen_string_literal: true

namespace :set_lot_area_to_payment_scheme do
  task run: :environment do
    Folder.joins(:payment_scheme).where(payment_schemes: { area: nil }).each do |folder|
      folder.payment_scheme.update_columns(area: folder.lot.area)
    end
  end
end
