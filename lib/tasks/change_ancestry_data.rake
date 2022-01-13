# frozen_string_literal: true

namespace :change_ancestry_data do
  desc "Run change_ancestry_data task"

  task run: :environment do
    realtor = Role.find_by(key: "realtor")
    salesman = Role.find_by(key: "salesman")
    coordinator = Role.find_by(key: "coordinator")
    manager = Role.find_by(key: "manager")
    vice_director = Role.find_by(key: "vice_director")
    director = Role.find_by(key: "director")

    Structure.where(role: realtor).each do |structure|
      ancestry = ""
      structure.parent_tree.reverse.each do |parent|
        ancestry += "#{parent.id}/"
      end
      structure.update(ancestry: ancestry[0..ancestry.size-2])
    end

    Structure.where(role: salesman).each do |structure|
      ancestry = ""
      structure.parent_tree.reverse.each do |parent|
        ancestry += "#{parent.id}/"
      end
      structure.update(ancestry: ancestry[0..ancestry.size-2])
    end

    Structure.where(role: coordinator).each do |structure|
      ancestry = ""
      structure.parent_tree.reverse.each do |parent|
        ancestry += "#{parent.id}/"
      end
      structure.update(ancestry: ancestry[0..ancestry.size-2])
    end

    Structure.where(role: manager).each do |structure|
      ancestry = ""
      structure.parent_tree.reverse.each do |parent|
        ancestry += "#{parent.id}/"
      end
      structure.update(ancestry: ancestry[0..ancestry.size-2])
    end

    Structure.where(role: vice_director).each do |structure|
      ancestry = ""
      structure.parent_tree.reverse.each do |parent|
        ancestry += "#{parent.id}/"
      end
      structure.update(ancestry: ancestry[0..ancestry.size-2])
    end

    Structure.where(role: director).each do |structure|
      ancestry = ""
      structure.parent_tree.reverse.each do |parent|
        ancestry += "#{parent.id}/"
      end
      structure.update(ancestry: ancestry[0..ancestry.size-2])
    end
  end
end