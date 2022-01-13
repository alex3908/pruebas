# frozen_string_literal: true

class LotStatusJob < ApplicationJob
  queue_as :high_priority

  def perform(folder_id)
    folder = Folder.find(folder_id)

    if folder.active?
      folder.lot.update(status: folder.step.lot_status)
    elsif folder.canceled? || folder.expired?
      folder.lot.update(status: Lot::STATUS[:FOR_SALE])
    end
  end
end
