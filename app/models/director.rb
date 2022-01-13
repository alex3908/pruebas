# frozen_string_literal: true

class Director < ApplicationRecord
  include Filterable

  belongs_to :user, class_name: "User"
  has_many :vice_directors, dependent: :destroy

  def status_label
    self.active ? "Aprobado" : "Pendiente"
  end
end
