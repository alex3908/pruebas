# frozen_string_literal: true

class ClientTicketJob < ApplicationJob
  queue_as :high_priority

  def perform(document, ticket)
    ticket_pdf = ClientTicket.new(ticket).to_pdf(:return_file)
    document.file_versions.create.file.attach(io: File.open(ticket_pdf.path), filename: "#{ticket.concept_key}_#{ticket.folder.id}.pdf")
  rescue StandardError => e
    raise e
  end
end
