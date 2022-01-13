# frozen_string_literal: true

class ProjectUser < ApplicationRecord
  include Filterable

  belongs_to :project
  belongs_to :user

  search_scope :project_id, -> (id) {
    where(project_id: id)
  }

  search_scope :user_id, -> (id) {
    where(user_id: id)
  }
end
