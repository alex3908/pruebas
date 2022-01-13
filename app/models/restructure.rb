# frozen_string_literal: true

class Restructure < ApplicationRecord
  include Filterable, InstallmentConcern
  CONCEPT = {
      FINANCING_MONTHLY: "financing_monthly",
      FINANCING_TIME: "financing_time",
      DOWN_PAYMENT_MONTHLY: "down_payment_monthly",
      DOWN_PAYMENT_TIME: "down_payment_time",
      RESTRUCTURE: "restructure",
      RESTRUCTURE_NEXT: "restructure_next",
      DAY: "day",
      DELAY_IMMEDIATE: "delay_immediate",
      DELAY_ALTERNATE: "delay_alternate",
      DELAY_LAST: "delay_last",
  }

  belongs_to :payment

  after_create :update_installments

  def self.down_payment_concept?(concept)
    [CONCEPT[:DOWN_PAYMENT_MONTHLY], CONCEPT[:DOWN_PAYMENT_TIME]].include?(concept)
  end

  def self.financing_concept?(concept)
    [CONCEPT[:FINANCING_MONTHLY], CONCEPT[:FINANCING_TIME]].include?(concept)
  end

  def self.not_amount_concept?(concept)
    [CONCEPT[:RESTRUCTURE], CONCEPT[:DAY], CONCEPT[:DELAY_IMMEDIATE], CONCEPT[:DELAY_ALTERNATE], CONCEPT[:DELAY_LAST]].include?(concept)
  end

  def self.amount_concept?(concept)
    !self.not_amount_concept?(concept)
  end

  def self.delay_concept?(concept)
    [CONCEPT[:DELAY_IMMEDIATE], CONCEPT[:DELAY_ALTERNATE], CONCEPT[:DELAY_LAST]].include?(concept)
  end

  def self.restructure_concept?(concept)
    [CONCEPT[:RESTRUCTURE], CONCEPT[:RESTRUCTURE_NEXT]].include?(concept)
  end

  def self.delay_concept
    concepts = Array.new
    concepts << ["Prórroga al mes inmediato", CONCEPT[:DELAY_IMMEDIATE]]
    concepts << ["Prórroga alternada", CONCEPT[:DELAY_ALTERNATE]]
    concepts << ["Prórroga al final", CONCEPT[:DELAY_LAST]]
    concepts
  end

  def self.translated_concept(concept)
    concepts = {
        CONCEPT[:FINANCING_MONTHLY] => "Abono a capital (monto)",
        CONCEPT[:FINANCING_TIME] => "Abono a capital (plazo)",
        CONCEPT[:DOWN_PAYMENT_MONTHLY] => "Abono a enganche (monto)",
        CONCEPT[:DOWN_PAYMENT_TIME] => "Abono a enganche (plazo)",
        CONCEPT[:RESTRUCTURE] => "Reestructura de saldo",
        CONCEPT[:DAY] => "Cambio de fecha",
        CONCEPT[:DELAY_IMMEDIATE] => "Prórroga al mes inmediato",
        CONCEPT[:DELAY_ALTERNATE] => "Prórroga alternada",
        CONCEPT[:DELAY_LAST] => "Prórroga al final",
    }
    concepts[concept]
  end

  def concept_label
    Restructure.translated_concept(self.concept)
  end

  def update_installments
    folder = self.payment.installment.folder
    reload_installments(folder)
  end
end
