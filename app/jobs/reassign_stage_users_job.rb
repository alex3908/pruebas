# frozen_string_literal: true

class ReassignStageUsersJob < ApplicationJob
  queue_as :high_priority

  def perform(job_status, ids, stage_id, action)
    action = action.to_sym
    users = User.where(id: ids)
    stage = Stage.find(stage_id)
    user_count = 0
    user_already_assigned_count = 0

    job_status.add_progress!("Asignando usuarios (#{users.count}, #{ids.size}) a #{stage.full_name}...")
    job_status.add_progress!("Gestionando usuarios ...")

    if action == :assign
      users.each do |user|
        if user.stage_users.where(stage_id: stage_id).exists?
          user_already_assigned_count += 1
        else
          stage_user = StageUser.new
          stage_user.stage_id = stage_id
          stage_user.user_id = user.id
          user_count += 1 if stage_user.save!
        end
      end
    elsif action == :deallocate
      users.each do |user|
        user_stage_permission = user.stage_users.where(stage_id: stage_id)

        if user_stage_permission.exists?
          user_stage_permission.first.off_project_seller if user_stage_permission.first.present?
          user_stage_permission.destroy_all
          user_count += 1
        else
          user_already_assigned_count += 1
        end
      end
    end

    job_status.add_progress!("Se enviaron un total de #{users.count}, de los cuales #{user_already_assigned_count} ya se encontraban #{get_action_status_translated(action)}. Se #{get_action_translated(action)} #{user_count} usuarios.")

    job_status.mark_completed!
  end

  def get_action_translated(action)
    if action == :assign
      "asignaron"
    elsif action == :deallocate
      "desasignaron"
    end
  end

  def get_action_status_translated(action)
    if action == :assign
      "asignados"
    elsif action == :deallocate
      "sin asignación"
    end
  end
end
