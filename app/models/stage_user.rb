# frozen_string_literal: true

class StageUser < ApplicationRecord
  include Filterable

  belongs_to :stage
  belongs_to :user

  after_create :on_project_seller
  before_destroy :off_project_seller

  def on_project_seller
    unless ProjectUser.where(user_id: self.user_id, project_id: self.stage.phase.project_id).exists?
      project_user = ProjectUser.new
      project_user.user_id = self.user_id
      project_user.project_id = self.stage.phase.project_id
      project_user.save!
    end
  end

  def off_project_seller
    stages_ids = Array.new
    self.stage.phase.project.phases.each do |phase|
      stages_ids << phase.stages.pluck(:id)
    end
    stage_users = self.user.stage_users.where(stage: stages_ids.flatten).count
    if stage_users <= 1
      project_user = ProjectUser.where(user_id: self.user_id, project_id: self.stage.phase.project_id)
      project_user.destroy_all if project_user.exists?
    end
  end
end
