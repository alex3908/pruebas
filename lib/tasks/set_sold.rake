# frozen_string_literal: true

namespace :set_sold do
  desc "Run set sold task"

  task run: :environment do
    Folder.where(status: Folder::STATUS[:ACTIVE]).each do |folder|
      if folder.step.is_last_one? && !folder.lot.sold?
        puts "======="
        puts folder.id
        Bugsang.notify("El #{folder.project.lot_entity_name} del expediente #{folder.id} no pudo ser marcado como vendido") unless folder.lot.update(status: Lot::STATUS[:SOLD])
      elsif (folder.fresh? || folder.under_revision?) && !folder.lot.reserved?
        puts "======="
        puts folder.id
        Bugsang.notify("El #{folder.project.lot_entity_name} del expediente #{folder.id} no pudo ser marcado como reservado") unless folder.lot.update(status: Lot::STATUS[:RESERVED])
      end
    end
  end
end
  