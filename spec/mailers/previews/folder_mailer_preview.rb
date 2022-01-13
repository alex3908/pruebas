# frozen_string_literal: true

class FolderMailerPreview < ActionMailer::Preview
  def notify_expiration
    @folder = Folder.last
    hours_passed = (Time.zone.now.to_time - @folder.calc_date.to_time) / 1.hours
    reason = "Sin apartado completo y sin comprobante de enganche"

    expired = []

    expired << {
      folio: @folder.id,
      project: @folder.project.name,
      phase: @folder.phase.name,
      stage: @folder.stage.name,
      lot: @folder.lot.name,
      start_date: @folder.calc_date.strftime("%d/%m/%Y %I:%M%p"),
      hours_from_start: hours_passed.round(2),
      reason: reason
    }

    FolderMailer.notify_expiration(@folder.client.email, expired.to_json, Time.zone.now.strftime("%d/%m/%Y %I:%M%p"))
  end
end
