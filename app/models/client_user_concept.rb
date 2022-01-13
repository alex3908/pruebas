# frozen_string_literal: true

class ClientUserConcept < ApplicationRecord
  validates :name, uniqueness: true
  validate :can_modify, on: :update
  belongs_to :role, optional: true
  has_many :client_users
  has_many :steps
  has_many :automated_email_client_concepts, dependent: :delete_all
  has_many :automated_emails, through: :automated_email_client_concepts
  has_many :roles_client_user_concepts, dependent: :delete_all
  has_many :roles, through: :roles_client_user_concepts

  enum key: { sales_executive: "sales_executive", customer_service: "customer_service", custom: "custom" }
  before_destroy :can_destroy

  def self.sales_executive
    ClientUserConcept.find_by(key: :sales_executive)
  end

  def can_destroy
    if sales_executive?
      errors.add(:base, "No puede eliminar este registro")
      throw :abort
    else
      if client_users.any?
        errors.add(:base, "No puede eliminar este registro existen usuarios relacionados")
        throw :abort
      end
    end
  end

  def can_modify
    if sales_executive?
      errors.add(:base, "No puede actualizar este registro")
      throw :abort
    end
  end
end
