namespace :assign_projects_to_users do
  desc "TODO"
  task run: :environment do

    users_without_reserve = User.where.not(id: User.can_reserve.pluck(:id)).pluck(:id)
    users_with_project_permission = User.where(id: users_without_reserve).with_permission(Permission.where("subject_class": 'Project',"action": 'read')).pluck(:id)
    users_with_stage_permission = User.where(id: users_with_project_permission).with_permission(Permission.where("subject_class": 'Project',"action": 'read')).pluck(:id)

    users = User.where(id: users_with_stage_permission)

    Project.where(active: true).each do |project|
      stages_id = project.phases.map { |phase| phase.stages.where(active: true).pluck(:id) }.flatten
      stages = Stage.where(id: stages_id)

      stages.each do |stage|
        users.each do |user|
          unless user.stage_users.where(stage: stage).exists?
            stage.sellers << user
            stage.save!
          end
        end
      end
    end

  end
end
