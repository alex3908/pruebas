# frozen_string_literal: true

namespace :users_branch do
  desc "Assigns branch to every user without branch"

  task assign: :environment do
      branch = Branch.find_or_create_by(name: "(Sin sucursal)", active: true)
      users = User.where(branch: nil).update_all(branch_id: branch.id)
      puts "Se le asignó sucursal a #{users} usuarios"
    end
end
