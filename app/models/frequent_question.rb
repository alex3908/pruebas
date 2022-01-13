# frozen_string_literal: true

class FrequentQuestion < ApplicationRecord
  enum status: [:hold, :released]
  belongs_to :user

  def status_label
    case status
    when "hold"
      str = "No publicado"
    when "released"
      str = "Publicado"
    else
      str = "Indefinido"
    end
    str
  end
end
