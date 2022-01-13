# frozen_string_literal: true

class LotAnnexeJob < ApplicationJob
  queue_as :high_priority

  def perform(status_id, lot_id)
    status = JobStatus.find_by(id: status_id)

    status.add_progress!("Generando documento...")
    lot = Lot.includes([
      stage: [
        blueprint: [blueprint_lots: :lot],
        phase: [:project, blueprint: :blueprint_stages]
      ]])
      .find_by(id: lot_id)

    annexes = LotAnnexe.new(lot).to_pdf(:return_file)
    status.file.attach(io: File.open(annexes.path), filename: "#{status.file_name}.pdf")

    status.add_progress!("Limpiando proceso...")

    status.mark_completed!
  rescue StandardError => e
    status.mark_failed!(e.to_s)
    status.log_error!(e)
    raise e
  end
end
