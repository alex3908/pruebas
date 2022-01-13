# frozen_string_literal: true

class Installment < ApplicationRecord
  CONCEPT = { LAST_PAYMENT: "last_payment", FINANCING: "financing", DOWN_PAYMENT: "down_payment", INITIAL_PAYMENT: "initial_payment" }
  TAB_TYPES = { NEW_PAYMENT: "new_payment", NEW_CAPITAL: "new_capital", NEW_RESTRUCTURE: "new_restructure", NEW_DATE: "new_date",  NEW_DELAY: "new_delay", NEW_ADDITIONAL_CONCEPT_PAYMENT: "new_additional_concept_payment" }
  enum concept: { last_payment: "last_payment", financing: "financing", down_payment: "down_payment", initial_payment: "initial_payment" }

  scope :active, -> { where(deleted_at: nil) }
  scope :custom, -> { where(deleted_at: nil, is_custom: true, concept: Installment::CONCEPT[:FINANCING]).order(number: :asc) }
  scope :no_custom, -> { where(deleted_at: nil, is_custom: false, concept: Installment::CONCEPT[:FINANCING]).order(number: :asc) }

  belongs_to :folder
  has_one :penalty
  has_many :commissions
  has_many :payments, -> { active }, dependent: :destroy
  has_many :history_payments, -> { not_deleted }, class_name: "Payment"

  accepts_nested_attributes_for :payments
  attr_accessor :residue

  def self.search(params)
    installments = Installment.includes(folder: [:client, [lot: [stage: [phase: :project]]]])
    installments = installments.where("client.id" => Client.where("LOWER(CONCAT(name, first_surname, second_surname)) LIKE LOWER(?)", "%#{params[:name].tr(" ", "%")}%".delete(" \t\r\n"))) if params[:name].present?
    installments = installments.where("client.id" => Client.where("LOWER(email) LIKE LOWER(?)", "%#{params[:email]}%".delete(" \t\r\n"))) if params[:email].present?
    installments = installments.where("projects.id" => params[:project]) if params[:project].present?
    installments = installments.where("phases.id" => params[:phase]) if params[:phase].present?
    installments = installments.where("stages.id" => params[:stage]) if params[:stage].present?
    installments = installments.where("branches.id" => params[:branch]) if params[:branch].present?
    installments = installments.where("folders.user_id" => User.where("LOWER(CONCAT(first_name, last_name)) LIKE LOWER(?)", "%#{params[:salesman].tr(" ", "%")}%")) if params[:salesman].present?
    installments = installments.where("installments.date BETWEEN ? and ?", params[:from_date].to_time.strftime("%Y-%m-%d %l:%M:%S"), params[:to_date].to_time.strftime("%Y-%m-%d %l:%M:%S")) if params[:from_date].present? && params[:to_date].present?
    installments
  end

  def total_paid
    paid = 0
    if self.payments.any?
      self.payments.each do |payment|
        paid += payment.amount unless payment.is_time_restructure
      end
    end
    paid
  end

  def bonus_paid
    paid = 0
    if self.payments.any?
      self.payments.each do |payment|
        if payment.cash_flow.present? && payment.cash_flow.cash_back
          paid += payment.amount
        end
      end
    end
    paid
  end

  def restructure_concepts(only_amount_restructure = true)
    restructure_concepts = []
    self.payments.each do |payment|
      if payment.restructure.present?
        if only_amount_restructure
          restructure_concepts << payment.restructure
        elsif Restructure.not_amount_concept?(payment.restructure.concept)
          restructure_concepts << payment.restructure
        end
      end
    end
    restructure_concepts
  end

  def concept_label
    concepts = {
        CONCEPT[:FINANCING] => "Parcialidad",
        CONCEPT[:DOWN_PAYMENT] => "Enganche",
        CONCEPT[:INITIAL_PAYMENT] => "Apartado",
    }
    concepts[concept]
  end

  def finance_position
    self.number
  end

  def label
    self.concept == CONCEPT[:INITIAL_PAYMENT] ? self.concept_label : self.concept_label + " " + self.number
  end

  def is_paid?
    self.total_paid >= self.total
  end

  def is_unpaid?
    !is_paid?
  end

  def capital_payment
    payment = payments.joins(:restructure)
                  .where("restructures.concept in (?)", [Restructure::CONCEPT[:FINANCING_TIME], Restructure::CONCEPT[:DOWN_PAYMENT_TIME]])
                  .take
    payment.present? ? payment.amount : 0
  end

  def has_payments?
    payments.active.any?
  end

  def is_overdue
    now = Time.zone.now
    penalty_amount = 0
    has_penalty = penalty.present? && penalty_amount.present? && penalty.active
    penalty_amount = penalty&.amount if has_penalty
    total_amount = total + penalty_amount
    is_paid =  total_paid >= total_amount
    residue = is_paid ? 0 : total_amount - total_paid
    overdue = date < now && residue > 0
    overdue
  end
end
