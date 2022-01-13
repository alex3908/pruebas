# frozen_string_literal: true

class Signer < ApplicationRecord
  has_many :contract_signers
  has_many :contracts, through: :contract_signers

  has_many :contract_non_signers, foreign_key: "non_signer_id"

  validates :name, :first_surname, :second_surname, :definition, :role, :company, presence: true
  validate :phone_format_verification
  scope :observers, ->() { where(is_an_observer: true) }

  def self.search(params)
    signers = Signer.all
    signers = signers.where("LOWER(CONCAT(name)) LIKE LOWER(?)", "%#{params[:name].tr(" ", "%")}%".delete(" \t\r\n")) if params[:name].present?
    signers = signers.where("LOWER(CONCAT(definition)) LIKE LOWER(?)", "%#{params[:definition].tr(" ", "%")}%".delete(" \t\r\n")) if params[:definition].present?
    signers = signers.where(role: params[:role]) if params[:role].present?
    signers = signers.where(company: params[:company]) if params[:company].present?
    signers
  end

  def self.set_params(params, sort_column, sort_direction)
    search(params).order(sort_column + " " + sort_direction)
  end

  def label
    "#{name} #{first_surname} #{second_surname}"
  end

  def sign_tag
    label.parameterize.underscore
  end

  private

    def phone_format_verification
      if self.phone.present?
        if self.phone.length < 10
          errors.add(:phone, I18n.t("errors.models.signer.main_phone.wrong_format"))
        end
      end
    end
end
