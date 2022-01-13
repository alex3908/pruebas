# frozen_string_literal: true

class LotAnnexe < DocumentHandler
  attr_reader :lot

  include FoldersHelper

  def initialize(lot)
    @lot = lot
  end

  protected
    def render_to_string
      [annexe_1, annexe_2, annexe_3].join("")
    end

    def annexe_1
      Annexe_1.new(lot.stage).render_to_string
    end

    def annexe_2
      Annexe_2.new(lot).render_to_string
    end

    def annexe_3
      Annexe_3.new(lot).render_to_string
    end
end
