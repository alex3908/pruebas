# frozen_string_literal: true

class DownloadableFile < ApplicationRecord
  belongs_to :step_role

  FILE_NAMES = {
    purchase_promise: "Promesa de compraventa",
    annexe_1: "Anexo 1",
    annexe_2: "Anexo 2",
    annexe_3: "Anexo 3",
    purchase_promise_attached: "Anexo PLD",
    amortization_cover: "Carátula Amortización",
    chepina: "Chepina",
    deposit_format: "Ficha de depósito",
    down_payment_receipt: "Recibos",
    purchase_conditions: "Condiciones de Compra",
    amortization_table: "Tabla de Amortización",
    promissory_note: "Pagaré"
  }
end
