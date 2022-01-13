# frozen_string_literal: true

class ClientUser < ApplicationRecord
  scope :client_user_concept_length, ->(client_id, concept_id) { where(client_id: client_id, client_user_concept_id: concept_id).count }

  belongs_to :client
  belongs_to :user
  belongs_to :client_user_concept
  validates_uniqueness_of :user_id, scope: [:client_id], message: "ya se encuentra registrado"
  before_create :validate_concept
  before_destroy :can_delete

  private

    def can_delete
      if client_user_concept.sales_executive?
        errors.add(:client_user_concept, "No se puede eliminar este usuario")
        throw :abort
      end
    end

    def validate_concept
      concept = ClientUserConcept.find_by(id: self.client_user_concept_id)
      max_users = concept.max_users

      if (self.class.client_user_concept_length(self.client_id, concept.id) + 1) > max_users
        errors.add(:client_user_concept, "No se pueden agregar más usuarios con el mismo concepto")
        throw :abort
      end
    end
end
