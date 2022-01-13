# frozen_string_literal: true

namespace :copy_structures do
  desc "Copy Structures"

  task run: :environment do
    director_role = Role.find_by(key: "director")
    vice_director_role = Role.find_by(key: "vice_director")
    manager_role = Role.find_by(key: "manager")
    coordinator_role = Role.find_by(key: "coordinator")
    salesman_role = Role.find_by(key: "salesman")

    Director.all.each do |element|
      structure = Structure.new
      structure.role = director_role
      structure.user = element.user
      structure.max_branches = element.max_branches
      structure.active = element.active
      structure.parent_id = nil
      structure.before_key = "director-#{element.id}"
      structure.active = true
      structure.save
    end

    ViceDirector.all.each do |element|
      parent = Structure.find_by(before_key: "director-#{element.director_id}")

      structure = Structure.new
      structure.role = vice_director_role
      structure.user = element.user
      structure.max_branches = element.max_branches
      structure.commission = element.commission
      structure.sale_commission = element.sale_commission
      structure.parent_id = parent.id
      structure.before_key = "vice-director-#{element.id}"
      structure.active = element.active
      structure.save
    end

    Manager.all.each do |element|
      parent = Structure.find_by(before_key: "vice-director-#{element.vice_director_id}")

      structure = Structure.new
      structure.role = manager_role
      structure.user = element.user
      structure.max_branches = element.max_branches
      structure.commission = element.commission
      structure.sale_commission = element.sale_commission
      structure.parent_id = parent.id
      structure.before_key = "manager-#{element.id}"
      structure.active = element.active
      structure.save
    end

    Coordinator.all.each do |element|
      parent = Structure.find_by(before_key: "manager-#{element.manager_id}")

      structure = Structure.new
      structure.role = coordinator_role
      structure.user = element.user
      structure.max_branches = element.max_branches
      structure.commission = element.commission
      structure.sale_commission = element.sale_commission
      structure.parent_id = parent.id
      structure.before_key = "coordinator-#{element.id}"
      structure.active = element.active
      structure.save
    end

    Salesman.all.each do |element|
      parent = Structure.find_by(before_key: "coordinator-#{element.coordinator_id}")

      structure = Structure.new
      structure.role = salesman_role
      structure.user = element.user
      structure.sale_commission = element.sale_commission
      structure.parent_id = parent.id
      structure.before_key = "salesman-#{element.id}"
      structure.active = element.active
      structure.save
    end
  end
end
  