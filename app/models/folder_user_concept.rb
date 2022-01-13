# frozen_string_literal: true

class FolderUserConcept < ApplicationRecord
  has_many :roles_folder_user_concepts, dependent: :delete_all
  has_many :roles, through: :roles_folder_user_concepts
  has_many :folder_users
  has_many :steps
  has_many :automated_email_user_concepts, dependent: :delete_all
  has_many :automated_emails, through: :automated_email_user_concepts
  before_destroy :check_dependencies

  def get_users
    User.where(is_active: true).where("role_id in (?)", self.roles.pluck(:id))
  end

  def check_dependencies
    errors.add(:base, "Hay expedientes con conceptos relacionados no se puede eliminar") unless FolderUser.where(folder_user_concept: self).empty?
    errors.add(:base, "Hay pasos con conceptos relacionados no se puede eliminar") unless Step.where(folder_user_concept: self).empty?
    errors.add(:base, "Hay correos automatizados con conceptos relacionados no se puede eliminar") unless AutomatedEmail.where(folder_user_concept: self).empty?
    throw(:abort) if errors.count > 0
  end
end
