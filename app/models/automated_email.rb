# frozen_string_literal: true

class AutomatedEmail < ApplicationRecord
  attr_accessor :emails

  has_many :automated_email_user_concepts
  has_many :folder_user_concepts, through: :automated_email_user_concepts, dependent: :delete_all
  has_many :automated_email_client_concepts
  has_many :client_user_concepts, through: :automated_email_client_concepts, dependent: :delete_all

  belongs_to :step, optional: true
  belongs_to :email_template
  belongs_to :folder_user_concept, optional: true
  before_validation :parse_emails_information
  validate :validate_emails_format
  validates :email_template_id, uniqueness: { scope: [:step_id, :reciever_type, :execution_type, :hidden_state] }
  enum recievers: { client: "client", user: "user", client_users: "client_users" }
  enum executions: { enter_step: "enter_step", exit_step: "exit_step", back_step: "back_step", reject_step: "reject_step" }
  enum hidden_states: { canceled: "canceled", expired: "expired" }
  enum types: { folders: "folders", clients: "clients" }
  enum sources: { api: "api", integration: "integration", public_quote: "public_quote", web: "web", all_sources: "all_sources" }

  def reciever
    I18n.t("activerecord.attributes.automated_email.recievers.#{reciever_type}")
  end

  def execution
    tag = (automated_type == AutomatedEmail.types[:folders]) ? "executions" : "sources"
    I18n.t("activerecord.attributes.automated_email.#{tag}.#{execution_type}")
  end

  def type
    automated_type == AutomatedEmail.types[:folders] ? "Expediente" : "Cliente"
  end

  def hidden_state_label
    I18n.t("activerecord.attributes.automated_email.hidden_states.#{hidden_state}")
  end

  def hidden_state_label
    I18n.t("activerecord.attributes.automated_email.hidden_states.#{self.hidden_state}")
  end

  def parse_emails_information
    unless emails.blank?
      self.emails_information = emails.split(",").map { |e| e.strip }
    end
  end

  def validate_emails_format
    unless emails.blank?
      self.emails_information.each do |email|
        unless Devise.email_regexp.match?(email)
          errors.add(:emails_information, ": El correo #{email} no es un correo valido")
        end
      end
    end
  end
end
