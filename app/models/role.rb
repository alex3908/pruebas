# frozen_string_literal: true

class Role < ApplicationRecord
  acts_as_paranoid

  scope :permitted, ->(is_permitted) do
    if is_permitted
      all
    else
      where(hidden: false)
    end
  end

  scope :evo, ->() { where(is_evo: true) }

  has_one :quote_role, dependent: :destroy
  has_many :users
  has_many :role_permissions
  has_many :permissions, through: :role_permissions
  has_many :roles_folder_user_concepts, dependent: :delete_all
  has_many :folder_user_concepts, through: :roles_folder_user_concepts
  has_many :roles_client_user_concepts, dependent: :delete_all
  has_many :client_user_concepts, through: :roles_client_user_concepts


  has_many :classifier_roles
  has_many :classifiers, through: :classifier_roles

  has_many :structures
  accepts_nested_attributes_for :quote_role
  before_destroy :validate_structures

  def self.max_level
    self.maximum(:level)
  end

  def self.last_of_the_structure
    return nil unless Role.max_level.present?
    self.find_by(level: Role.max_level)
  end

  def self.evo_structure
    self.where.not(level: nil).order(level: :asc)
  end

  def has_structures?
    structures.size > 0
  end

  def validate_structures
    self.errors.add("", "No es posible eliminar el rol debido a que ya cuenta con niveles asociados") if level.present? && structures.size > 0
  end

  def self.root
    find_by(level: 0)
  end

  def is_root?
    self.id == Role.root&.id
  end

  def next_level
    return nil if self.level.nil?
    self.level + 1
  end

  def previous_level
    return nil if self.level.nil?
    return nil if self.level.zero?
    self.level - 1
  end

  def has_children?
    self.next.present?
  end

  def childrens
    Role.where("level > ? ", level).order(level: :asc)
  end

  def next
    next_level = self.next_level
    return nil if next_level.nil?
    Role.find_by(level: next_level)
  end

  def sale_commission_percentage
    convert_percentage(self.sale_commission)
  end

  def commission_monitoring_percentage
    convert_percentage(self.commission_monitoring)
  end

  def leader
    previous_level = self.previous_level
    return nil if previous_level.nil?
    Role.find_by(level: previous_level)
  end

  private

    def convert_percentage(value)
      return 0 unless value.present?
      value.to_f / 100
    end
end
