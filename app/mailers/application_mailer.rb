# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.secrets.app_emailer
  layout "mailer"

  protected

    def build_pdf(pdf)
      WickedPdf.new.pdf_from_string(pdf, lowquality: true, zoom: 1, dpi: 75, page_size: "Letter", margin: {
        top: 0,
        bottom: 0,
        left: 0,
        right: 0
      })
    end

    def mailgun_options
      {
        "tracking-opens" => true,
        "tracking-clicks" => "htmlonly"
      }
    end
end
