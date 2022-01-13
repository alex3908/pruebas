# frozen_string_literal: true

namespace :remove_inactive_structures do
  desc "Run remove_inactive_structures task"

  task run: :environment do
    User.where(is_active: false).each do |user|
      if user.structure.present?
        if user.structure.children.count <= 0
          user.structure.destroy
        else
          puts "El usuario #{user.label} tiene subordinados"
        end
      end
    end

    User.where(is_active: false).each do |user|
      salesman_role = Role.find_by(key: "salesman")
      if user.structure.nil? && user.role.is_evo
        user.update(role: salesman_role)
      end
    end

    Structure.all.each do |structure|
      structure.destroy if structure.user.nil? && structure.children.blank?
    end
  end
end