# frozen_string_literal: true

class ContractAnnexe < ApplicationRecord
  include RailsSortable::Model
  set_sortable :order

  belongs_to :contract

  # THIS IS THE ANNEXES DEFAULT ORDER
  ANNEXES_NAMES = {
    PLD: "Anexo PLD",
    AMORTIZATION_TABLE: "Tabla de Amortización",
    STAGE_ANNEXES: "Anexos de Etapa",
    LOT_ANNEXES: "Anexos de Lote",
    FOLDER: "Documentos del Expediente",
    CLIENT: "Documentos de Clientes",
    ADDITIONAL_ANNEXES: "Anexos adicionales",
    PHASE: "Fase como Anexo",
    STAGE: "Etapa como Anexo",
    LOT: "Lote como Anexo",
    PURCHASE_CONDITIONS: "Condiciones de Compra"
  }
end
