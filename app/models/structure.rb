# frozen_string_literal: true

class Structure < ApplicationRecord
  acts_as_paranoid
  include Filterable
  has_ancestry cache_depth: true
  belongs_to :user, required: false
  belongs_to :role
  after_update :binnacle

  def self.roots_label
    role = Role.find_by(key: "director")
    return "" unless role.present?
    role.name.pluralize(:es)
  end

  def self.root_nodes
    initial_role = self.initial_role
    Structure.where(role_id: initial_role&.id).or(Structure.where(ancestry_depth: initial_role&.level))
  end

  def self.root_node_label
    self.initial_role&.name
  end

  def self.initial_role
    Role.root
  end

  def status_label
    self.active ? "Aprobada" : "Pendiente"
  end

  def direct_subordinates_active
    users = []
    children.each do |structure|
      users << structure.user_id if structure.user.present? && (structure.user.is_active || structure.user.nil?)
    end
    users
  end

  def level(index_level)
    structure = path.at_depth(index_level).first
    if structure.present? && structure.user.present? && structure.user.is_active
      structure
    end
  end

  def current_staff_structure
    evo_structure = Role.evo_structure
    build_evo_structure(evo_structure)
  end

  def staff_structure(evo_structure)
    build_evo_structure(evo_structure)
  end

  def search_node(key)
    path.joins(:role).includes(:role).where(roles: { key: key }).first
  end

  def binnacle
    unless Current.user.nil?
      filtered_changes = previous_changes
      previous_changes.keys.each do |attr_name, attr_value|
        if previous_changes[attr_name][0].nil?
          filtered_changes[attr_name][0] = ""
        end

        if previous_changes[attr_name][1].nil?
          filtered_changes[attr_name][1] = ""
        end
      end

      element_changes = "#{filtered_changes.except(:updated_at)}".gsub("=>", ":")

      if element_changes != "{}"
        @log = {
            date: Time.zone.now,
            element_changes: element_changes,
            element: "structure",
            element_id: self.id,
            user_id: Current.user.id
        }
        Log.create(@log)

        if self.user.present?
          if filtered_changes[:user_id].present? && filtered_changes[:user_id][1].present?
            structure = self.parent&.user&.present? ? self.parent&.user&.label : self.parent&.id
            filtered_changes[:structure] = ["", "#{structure}"] if structure.present?
            filtered_changes.delete(:user_id)
            filtered_changes.delete(:active)
          end

          element_changes = "#{filtered_changes.except(:updated_at)}".gsub("=>", ":")

          @log = {
              date: Time.zone.now,
              element_changes: element_changes,
              element: "user",
              element_id: self.user_id,
              user_id: Current.user.id
          }
          Log.create(@log)
        end
      end
    end
  end

  private

    def build_evo_structure(evo_structure)
      staff = {}
      current_structure = path.joins(:role).includes(:role).where(roles: { key: evo_structure.pluck(:key) })

      evo_structure.each do |evo|
        node_structure = current_structure.select { |structure| structure.role&.key == evo.key }.first
        staff[evo.key] = node_structure
      end
      staff
    end
end
